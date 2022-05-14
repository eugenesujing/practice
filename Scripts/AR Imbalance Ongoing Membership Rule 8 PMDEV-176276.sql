/*
Author: Jing Su
Created Date: 2022-04-04
Modified Date: 2022-05-04

PMDEV-176276

What this script does:
	1. Insert AR GL for imbalanced ongoing membership invoice (forfeited)

What you need to update:
	1.Update the DB number.
	2.Update the PMDEV- number.
	3.Update the Transaction RecordName.
	4.Execute. If successful, the following result will show :
	  'Executed Successfully!'


Alert:
	1.It will only fix for the invoice that has a full amount forfeit.
	2.If the invoice is still imbanlanced after insertion, a warning will be raised.
	3.If the EffectivateDate is later than 3 calendar days, there will be warning and no GL will be inserted for that invoice.
	  Please comment out the 'if' statement for GL insertion or change the date difference limit if EffectivateDate is still
	  within 3 business days but not 3 calendar days.
*/


use G423595;
	
	DECLARE @transactions Table (recordname nvarchar(30))
	INSERT INTO @transactions Values ('226240'),('242962'),('258446'),('226391')--change the recordname based on JIRA tickets


	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();

	drop table if exists #rule8
	 --delete from Custom.GLJournal where ReferenceDescription = 'PMFIX for PMDEV-176276'
	select ROW_NUMBER() OVER( ORDER BY t.modifieddate) RowID, j.GLAccountName, j.glnumber, j.glaccountid, j.reference, j.reference_objectid, t.ModifiedDate, j.TransactionID , i.id as invoiceid, sum(j.NetBalance) as glnetbalance
	into #rule8
	from custom.GLJournal j
	left join Custom.[Transaction] t on t.ID = j.TransactionID
	left join Custom.Invoice i on j.InvoiceId = i.ID
	--left join Custom.Payment p on p.Invoice = i.id
	where t.RecordName in (select recordname from @transactions)
	and j.invoiceid is not null 
	and i.Status = 5
	and j.reference_objectid = (select id from Framework.Object where tablename in ('Contact'))
	and exists (select * from Custom.Payment p where p.Invoice = i.ID and p.PaymentMethod = -1 and p.Amount = i.Amount)
	group by j.GLAccountName, j.glnumber, j.glaccountid, j.reference, j.reference_objectid, t.ModifiedDate, j.TransactionID , i.id
	having sum(j.NetBalance) <> 0
	
	--select * from #rule8

	DECLARE @NumberRecords int
	DECLARE @RowCount int
	DECLARE @EffectiveDate datetime
	DECLARE @Contact uniqueidentifier
	DECLARE @Invoice uniqueidentifier

	SELECT @NumberRecords = max (RowID) from #rule8
	SET @RowCount = 1
	DECLARE @InsertedCount int = 0

	DECLARE @NumberOfTransactions int
	select @NumberOfTransactions = count(distinct(TransactionID)) from #rule8

WHILE @RowCount <= @NumberRecords
BEGIN
	Select @Contact = reference, @Invoice = invoiceid
	from #rule8
	where RowID = @RowCount

	--find the imbalanced batch ID
	DECLARE @JournalBatchId int
	Select @JournalBatchId = (select max(JournalBatchId) from Custom.GLJournal
	where Reference = @Contact and InvoiceId = @Invoice)
	

	--create new recordname for gljournal
	DECLARE @RecordName int
    SELECT @RecordName = MAX(CAST(SUBSTRING(RecordName, 7, 6) AS int)) FROM Custom.GLJournal
    WHERE RecordName LIKE 'GLFIX-[0-9]%'
    IF @RecordName IS NULL SET @RecordName = 0


	DECLARE @Debit decimal(20, 2)
	DECLARE @Credit decimal(20, 2)

	Select @Debit = CASE
		WHEN glnetbalance >0
		THEN 0
		ELSE glnetbalance*-1
		END,
		@Credit = CASE
		WHEN glnetbalance >0
		THEN glnetbalance
		ELSE 0
		END
	from #rule8
	where RowID = @RowCount

	select @EffectiveDate = (select i.ModifiedDate from #rule8 r left join Custom.Invoice i on i.id = r.invoiceid where r.RowID = @RowCount)
	if(@UTCNow - @EffectiveDate>'1900-01-04 00:00:00.000')
	begin
		select 'Warning: The following EffectivateDate is later than 3 calandar days!!!'
		select * from #rule8
		where RowID = @RowCount
	end
	
	if(@UTCNow - @EffectiveDate<'1900-01-04 00:00:00.000')
	begin
		-- [Custom].[GLJournal] for AR	
		SET @InsertedCount = @InsertedCount + 1
		SET @RecordName = @RecordName + 1		
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), t.LocationId, @DatafixUserID, @DatafixUserID, @Debit, @Credit, 'PMFIX for PMDEV-176276', r.GLAccountName, r.GLNumber, r.Reference, r.Reference_ObjectID, r.GLAccountID, r.TransactionID, i.ModifiedDate, r.invoiceid, @JournalBatchId, 'None'
		FROM #rule8 r
			left join Custom.[Transaction] t on t.id = r.transactionid
			left join custom.invoice i on i.ID = r.invoiceid
		WHERE RowID = @RowCount
	end

		

	SET @RowCount = @RowCount + 1


END	
	--check if there is still imbalanced invoice after the above fix
	drop table if exists #rule8qa
	select ROW_NUMBER() OVER( ORDER BY t.modifieddate) RowID, j.GLAccountName, j.glnumber, j.glaccountid, j.reference, j.reference_objectid, t.ModifiedDate, j.TransactionID , i.id as invoiceid, sum(j.NetBalance) as glnetbalance
	into #rule8qa
	from custom.GLJournal j
	left join Custom.[Transaction] t on t.ID = j.TransactionID
	left join Custom.Invoice i on j.InvoiceId = i.ID
	where t.RecordName in (select recordname from @transactions)
	and j.invoiceid is not null 
	and i.Status = 5
	and j.reference_objectid = (select id from Framework.Object where tablename in ('Contact'))
	and exists (select * from Custom.Payment p where p.Invoice = i.ID and p.PaymentMethod = -1 and p.Amount = i.Amount)
	group by j.GLAccountName, j.glnumber, j.glaccountid, j.reference, j.reference_objectid, t.ModifiedDate, j.TransactionID , i.id
	having sum(j.NetBalance) <> 0
	
	SELECT @NumberRecords = max (RowID) from #rule8qa
	if(@NumberRecords>0)
	begin
		select 'Warning:' + CAST(@InsertedCount AS varchar(5)) + ' row(s) has/have been inserted. But the following invoice(s) is/are still not balanced!'
		select * from #rule8qa
	end
	else
	begin
		select 'Executed Successfully! ' +CAST(@NumberOfTransactions AS varchar(5)) +' transaction(s) has/have been fixed.' +CAST(@InsertedCount AS varchar(5)) + ' row(s) has/have been inserted. And every invoice is balanced after execution.'
	end