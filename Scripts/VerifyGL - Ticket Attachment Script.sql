/* ========================================================
Author				: Zak Osman
Created Date		: 2021/06/04
Date Last Modified	: 2021/06/04


-------- Script Guidelines ---------
https://perfectmind.atlassian.net/wiki/display/PerfectMind/Code+Guideline+-+Database

-- ========================================================= */
-- This is a script to attach JIRA tickets to verifyGL issues in the daily email report.

USE [VerifyGL]

	--

	DECLARE @TestcaseIDs TABLE (testcaseID INT NOT NULL)
	INSERT INTO @TestcaseIDs VALUES ('7064') -- Testcases linked to ticket


	DECLARE @ENVs TABLE (ENV nvarchar(128) NOT NULL)
	INSERT INTO @ENVs VALUES ('alpha'); -- Must be in ('alpha', 'beta', 'staging', 'internal', 'hfalpha', 'hfstaging', 'hfbeta')

	DECLARE @TicketName varchar(20) = 'PMDEV-174194' -- Ticket Name (PMDEV-XXXXXX)
	DECLARE @URL nvarchar(500) = 'https://jira001.perfectmind.com/jira/browse/PMDEV-174194' -- Full URL

	--

IF NOT EXISTS (SELECT 1 FROM [dbo].[Tickets] WHERE (URL = @URL AND TestRunEnv in (SELECT ENV FROM @ENVs) AND TestcaseID IN (SELECT TestCaseID FROM @TestcaseIDs)))
BEGIN

	WHILE (exists (SELECT TOP 1 TestCaseID FROM @TestcaseIDs ORDER BY TestCaseID))

		BEGIN

		DECLARE @TestcaseID int = (SELECT TOP 1 TestCaseID FROM @TestcaseIDs ORDER BY TestCaseID)
		DECLARE @ENVtemp TABLE (ENV nvarchar(128) NOT NULL)
		INSERT INTO @ENVtemp SELECT * FROM @ENVs


		WHILE (exists (SELECT TOP 1 ENV FROM @ENVtemp ORDER BY ENV))

			BEGIN
			
			DECLARE @TicketID uniqueidentifier = NEWID()
			DECLARE @ENV nvarchar(128) = (SELECT TOP 1 ENV FROM @ENVtemp ORDER BY ENV)

			INSERT INTO [dbo].[Tickets]
					   ([ID]
					   ,[TicketName]
					   ,[URL]
					   ,[CreatedDate]
					   ,[ModifiedDate]
					   ,[TestCaseID]
					   ,[TestRunEnv])
				 VALUES
					   (@TicketID
					   ,@TicketName
					   ,@URL
					   ,GETUTCDATE()
					   ,GETUTCDATE()
					   ,@TestcaseID
					   ,@ENV
					   )

			UPDATE [dbo].[Issues]
			SET [ModifiedDate] = GETUTCDATE()
				,TicketID = @TicketID
			WHERE id in (
						select i.id
						from dbo.DetectionLog d
						left join dbo.Issues i on i.TestcaseID = d.TestcaseID
							and i.TestrunDBName = d.TestrunDBName
							and i.TestrunID = d.TestrunID
						where d.TestcaseID = @TestcaseID
							and d.HasIssues = 1
							and d.TestrunEnv = @ENV
							and d.CreatedDate >= ISNULL(
							   (select top 1 dl.CreatedDate
								from dbo.DetectionLog dl
								where dl.TestcaseID = d.TestcaseID
									and dl.TestrunEnv = d.TestrunEnv
									and dl.HasIssues = 0	
								order by dl.CreatedDate DESC
								), d.CreatedDate)
						)

			DELETE FROM @ENVtemp WHERE ENV = @ENV

			END

		DELETE FROM @TestcaseIDs WHERE TestCaseID like @TestcaseID

		END


END