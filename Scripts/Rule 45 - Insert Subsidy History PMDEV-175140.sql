/*
Author: Jing Su
Created Date: 2022-03-30
Modified Date: 2022-04-06

PMDEV-175140

What this script does:
	1.Insert into SubsidyHistory table a new record for the subsidy payment
	2.Reverse the incorrect GL posting to 'Payment GL'
	3.Repost GL to the correct subsidy GL account
	
Add new subsidy history given the payment recordname
	1.Change the DB number
	2.Change the PMDEV number
	3.Change the payment recordname
	4.Execute

Alert:
	1.If current date fix, please set @EffectiveDate = @UTCNow
	2.This script only works for subsidy refund that has a corresponding subsidy payment previously
*/
use G423453;

DECLARE @DryRun bit = 0; -- If 1, rolls back the transaction afterward.
DECLARE @TxnName varchar(32) = 'PMDEV-175140'

--select newid()
--select * from custom.subsidyhistory s where s.recordname like 'SHFIX%' order by recordname

BEGIN
	IF @DryRun = 1 BEGIN
		RAISERROR ('DryRun is enabled. No changes will be committed', 11, 1);
	END
	BEGIN TRANSACTION @TxnName;
	
	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();


	drop table if exists #rule45

	Select ROW_NUMBER() OVER( ORDER BY p.createddate) RowID, Newid() as SubsidyID, p.ID as PaymentID, sh.TransactionId, p.CreatedDate, sh.SubsidyAllocationId, 
	Case When p.Amount <0 Then p.Amount *-1 Else p.Amount End as Amount,
	Case When p.Amount <0 Then '2' Else '1' End as sType
	into #rule45
	from Custom.Payment p
	left join Custom.SubsidyHistory sh on sh.paymentid = p.refundpaymentid
	--change the payment recordname
	Where p.recordname in ('PYMT-47293','PYMT-47294','PYMT-47320','PYMT-47303','PYMT-47298','PYMT-47304','PYMT-47290','PYMT-47315','PYMT-52056','PYMT-39381','PYMT-52047','PYMT-47297','PYMT-47291','PYMT-47321','PYMT-47314')

	select * from #rule45
	
	DECLARE @SubsidyHistoryID Uniqueidentifier
	DECLARE @PaymentID Uniqueidentifier
	DECLARE @TransactionID Uniqueidentifier
	DECLARE @CartitemID Uniqueidentifier
	DECLARE @SubsidyAllocationID Uniqueidentifier
	DECLARE @EffectiveDate datetime
	DECLARE @Amount decimal(20,2)
	DECLARE @Type int

	DECLARE @NumberRecords int
	DECLARE @RowCount int

	SELECT @NumberRecords = max (RowID) from #rule45 
	SET @RowCount = 1

	WHILE @RowCount <= @NumberRecords
	BEGIN
		DECLARE @SHRecordName int
		SELECT @SHRecordName = MAX(CAST(SUBSTRING(RecordName, 7, 5) AS int)) FROM Custom.SubsidyHistory
		WHERE RecordName LIKE 'SHFIX-[0-9]%'
		IF @SHRecordName IS NULL SET @SHRecordName = 0

		--create new recordname for gljournal
		DECLARE @GLRecordName int
		SELECT @GLRecordName = MAX(CAST(SUBSTRING(RecordName, 7, 6) AS int)) FROM Custom.GLJournal
		WHERE RecordName LIKE 'GLFIX-[0-9]%'
		IF @GLRecordName IS NULL SET @GLRecordName = 0

		
		Select @SubsidyHistoryID = r.SubsidyID, @PaymentID = r.PaymentID, @TransactionID = r.TransactionId, @Amount = r.Amount,
		 @EffectiveDate = r.CreatedDate, @SubsidyAllocationID = r.SubsidyAllocationId, @Type = r.sType
		From #rule45 r
		Where r.RowID = @RowCount

		--SET @EffectiveDate = @UTCNow

		--If the original payment refers to more than 1 cartitem, find the correct caritemID by using the refund journalbatch
		IF (select count(RowID) from #rule45 where PaymentID  = @PaymentID) >1
		BEGIN
			SET @CartitemID =  (select top 1 reference from Custom.GLJournal 
			where Reference_ObjectID = '39D4288F-7468-4A3C-920E-96B4D0D51E97' and  JournalBatchId = 
			(select top 1 JournalBatchId from Custom.GLJournal where Reference = @PaymentID))
		END
		ELSE
		BEGIN
			SET @CartitemID = (select CartItemId from Custom.SubsidyHistory sh
			left join custom.payment p on p.refundpaymentid = sh.paymentid
			where p.ID = @PaymentID)
		END


	if ((select count(reference) from custom.gljournal where Reference = @PaymentID) =1)
	BEGIN
		--INSERT a new subsidy history record
		SET @SHRecordName = @SHRecordName + 1	
		INSERT INTO [Custom].[SubsidyHistory]
	           ([ID]
	           ,[CreatedDate]
	           ,[CreatedByUserID]
	           ,[ModifiedDate]
	           ,[ModifiedByUserID]
	           ,[SubsidyAllocationId]
	           ,[CartItemId]
	           ,[PaymentId]
	           ,[TransactionId]
	           ,[Amount]
	           ,[Type]
	           ,[Quantity]
	           ,[RecordName])
	     VALUES
	           (@SubsidyHistoryID
	           ,@EffectiveDate
	           ,@DatafixUserID
	           ,@UTCNow
	           ,@DatafixUserID
	           ,@SubsidyAllocationID -- SubsidyAllocationId
	           ,@CartitemID -- CartItemId
	           ,@PaymentID -- PaymentId
	           ,@TransactionID -- TransactionID
	           ,@Amount -- Amount
	           ,@Type -- Type 1 = payment, 2 = refund
	           ,'1'
	           ,'SHFIX-' + RIGHT('00000' + CAST(@SHRecordName as varchar(20)), 5))
		
		DECLARE @JournalBatchID int
		DECLARE @InvoiceID uniqueidentifier
		DECLARE @LocationID uniqueidentifier
		SELECT @JournalBatchId =  j.Journalbatchid, @InvoiceID = j.Invoiceid, @LocationID = j.LocationId
		from Custom.GLJournal j
		WHERE j.Reference = @PaymentID and j.TransactionID = @TransactionID



		-- [Custom].[GLJournal] for PaymentGL to reverse the incorrect posting to PaymentGL
		SET @GLRecordName = @GLRecordName + 1		
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@GLRecordName as varchar(20)), 6),j.LocationID , @DatafixUserID, @DatafixUserID, j.Credit, j.Debit, 'PMFIX for PMDEV-175140', j.GLAccountName, j.GLNumber, @PaymentID, j.Reference_ObjectID, j.GLAccountID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchID, 'None'
		FROM Custom.GLJournal j
		WHERE j.Reference = @PaymentID and j.TransactionID = @TransactionID


		-- [Custom].[GLJournal] for Subsidy GL	
		SET @GLRecordName = @GLRecordName + 1		
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@GLRecordName as varchar(20)), 6),j.LocationID , @DatafixUserID, @DatafixUserID, CASE WHEN @Type = 1 THEN @Amount ELSE 0 END, CASE WHEN @Type = 1 THEN 0 ELSE @Amount END, 'PMFIX for PMDEV-175140', j.GLAccountName, j.GLNumber, @SubsidyHistoryID, j.Reference_ObjectID, j.GLAccountID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchID, 'None'
		FROM Custom.Payment p
		left join
		(select top 1 * from Custom.GLJournal j1 where j1.Reference_ObjectID = 'C6283D3D-FFBD-4B53-ABDF-63C6D855F1AE' and j1.TransactionID = @TransactionID) j
		on j.LocationID = p.LocationID
		WHERE p.id = @PaymentID
	
	END

	SET @RowCount = @RowCount + 1


	END


	IF @DryRun = 1 BEGIN
		ROLLBACK TRANSACTION @TxnName;
		RAISERROR ('DryRun was enabled. No changes were committed', 11, 1);
	END ELSE BEGIN
		COMMIT TRANSACTION @TxnName;
	END
END
