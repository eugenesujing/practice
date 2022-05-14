/*
Author: Jing Su
Created Date: 2022-03-24
Modified Date: 2022-05-13

PMDEV-XXXXXX

What this script does:
	1.Forfeit remaining balance for invoices
	2.Update column 'PaseAmendment' as 1
	3.Refund payments to account credit, if there's any 
	(partial payment, partial refund, forfeit payment have been taken into consideration when this script was written)
	4.Create GL journals for credit history
	5.If it's rule 43 fix, transaction will be updated as failed

What you should do:
	1.Change the DB number
	2.Change the PMDEV number
	3.Change the @BackDate
	4.Change the Invoice record name
	(5.Change the @Rule43 = 1 if it's rule 43 fix)
	6.Execute and double check the results
	


Alert: 
	1. This script does not reverse the double posting GLs, you need to reverse them by yourself!!!
	2. If this script fails to fix the issue correctly, you can always refer to the old version and forfeit/update/refund manually				
	3. If all invoices entered have been forfeited/refunded already, then a warning will be displayed.
	4. If there's payment still in process, then a warning will be displayed.
*/
use G424063;

DECLARE @DryRun bit = 0; -- If 1, rolls back the transaction afterward.
DECLARE @TxnName varchar(32) = 'PMDEV-XXXXXX'

BEGIN
	IF @DryRun = 1 BEGIN
		RAISERROR ('DryRun is enabled. No changes will be committed', 11, 1);
	END
	BEGIN TRANSACTION @TxnName;
	
	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();
	DECLARE @BackDate datetime = '2022-03-24 00:00:00.000';

	DECLARE @Rule43 int = 0;

	DECLARE @Txn_ObjectID uniqueidentifier = '835E2315-51D5-46F5-A260-236E858A7534';
	DECLARE @Inv_ObjectID uniqueidentifier = 'F9822D6C-31ED-41D2-81C7-F8E8DE242E79';
	DECLARE @Pay_ObjectID uniqueidentifier = '67F02CDA-018F-4F1D-ABC0-960ED27F9006';

	drop table if exists #doublePost

	Select ROW_NUMBER() OVER( ORDER BY i.recordname) RowID, i.recordname, i.ID as InvoiceID, i.Amount as InvoiceAmount, i.Status as InvoiceStaus
		, i.RemainingBalance, p.ID as PaymentID ,p.Amount as paymentAmount
		, CASE WHEN p.ID is not NULL and p.PaymentMethod <> -1 and p.Status = 0 and p.Amount >0 THEN p.Amount ELSE 0 END as toBeRefundAmount
		, CASE WHEN p.ID is not NULL and p.PaymentMethod <> -1 and p.Status = 0 and p.Amount >0 THEN newid() ELSE NULL END as newRefundPaymentID
		, CASE WHEN p.ID is not NULL and p.PaymentMethod <> -1 and p.Status = 0 and p.Amount >0 THEN newid() ELSE NULL END as newCreditHistoryID
		,p.Status as PaymentStatus, p.PaymentMethod, i.TransactionID
	into #doublePost
	from Custom.Invoice i
	left join Custom.Payment p on p.Invoice = i.ID
	--change the invoice recordname
	Where i.recordname in ('121326', '121327', '121328', '121329')	
	
	--if there's partial refund, the remaining payment will be refunded later
	UPDATE #doublePost 
	SET newRefundPaymentID = NEWID(), newCreditHistoryID = NEWID(), toBeRefundAmount = paymentAmount - (select sum(p.Amount*-1) from Custom.Payment p where p.RefundPaymentId = PaymentID)
	WHERE paymentAmount > (select sum(p.Amount*-1) from Custom.Payment p where p.RefundPaymentId = PaymentID)

	if exists (select rowid from #doublePost where InvoiceStaus = 1)
	begin
		select 'There is payment in progress, not able to perform refunding. Please wait until it is settled.' as WARNING
		set @dryrun = 1
	end
	
	--select * from #doublePost

	DECLARE @NumberRecords int
	DECLARE @RowCount int
	DECLARE @RowAffected int = 0

	SELECT @NumberRecords = max (RowID) from #doublePost
	SET @RowCount = 1

	DECLARE @PYRecordName int
	SELECT @PYRecordName = MAX(CAST(SUBSTRING(RecordName, 9, 5) AS int)) FROM Custom.Payment
	WHERE RecordName LIKE 'PYMTFIX-[0-9]%'
	IF @PYRecordName IS NULL SET @PYRecordName = 0

	DECLARE @CRRecordName int
	SELECT @CRRecordName = MAX(CAST(SUBSTRING(RecordName, 7, 5) AS int)) FROM Custom.CreditHistory
	WHERE RecordName LIKE 'CRFIX-[0-9]%'
	IF @CRRecordName IS NULL SET @CRRecordName = 0

	DECLARE @GLRecordName int
    SELECT @GLRecordName = MAX(CAST(SUBSTRING(RecordName, 7, 6) AS int)) FROM Custom.GLJournal
    WHERE RecordName LIKE 'GLFIX-[0-9]%'
    IF @GLRecordName IS NULL SET @GLRecordName = 0

	WHILE @RowCount <= @NumberRecords
	BEGIN
		DECLARE @InvoiceID uniqueidentifier = (select InvoiceID from #doublePost where RowID = @RowCount)
		DECLARE @RemainingBalance decimal(20,2) = (select RemainingBalance from custom.invoice where id = @InvoiceID)

		--Insert forfeit payment for each invoice that has non-zero remaining balance
		IF @RemainingBalance <> 0
		BEGIN
			SET @RowAffected = @RowAffected + 1
			SET @PYRecordName = @PYRecordName + 1
			DECLARE @ForfeitPaymentID Uniqueidentifier = newid()

			INSERT INTO [Custom].[Payment]
			   ([ID]
			   ,[RecordName]
			   ,[LocationId]
			   ,[CreatedDate]
			   ,[CreatedByUserID]
			   ,[ModifiedDate]
			   ,[ModifiedByUserID]
			   ,[Status]
			   ,[Amount]
			   ,[PaymentType]
			   ,[PaymentMethod]
			   ,[PaymentStatus]
			   ,[Type]
			   ,[PaymentReturned]
			   ,[Invoice]
			   ,[Details]
			   )
			SELECT
			   @ForfeitPaymentID
			   ,'PYMTFIX-' + RIGHT('00000' + CAST(@PYRecordName as varchar(20)), 5)
			   ,i.LocationId -- location ID
			   ,@BackDate
			   ,@DatafixUserID
			   ,@UTCNow
			   ,@DatafixUserID
			   ,0 --status
			   ,@RemainingBalance --amount
			   ,1 --payment type
			   ,-1 --payment method
			   ,0 --payment status
			   ,3 --type
			   ,0 --payment returned
			   ,i.ID
			   ,'PM Support (PMDEV-XXXXXX): fix facility contract amendment'          
			FROM #doublePost d
				left join Custom.Invoice i on i.ID = d.InvoiceID
			WHERE RowID = @RowCount

			INSERT INTO Custom.DataChange
				(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
				VALUES (
					@Pay_ObjectID, -- Object_ID (Payment)
					@ForfeitPaymentID, -- RecordID (reference)
					NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

			UPDATE Custom.Invoice	
			SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = @RemainingBalance
				,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
			WHERE ID = @InvoiceID;

		END

		--update pastamendment as 1
		IF (Select PastAmendment from Custom.Invoice where id = @InvoiceID) = 0
		BEGIN
			
			UPDATE Custom.Invoice	
			SET PastAmendment = 1
				,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
			WHERE ID = @InvoiceID;

			INSERT INTO Custom.DataChange
			(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
			VALUES (
				@Inv_ObjectID, -- Object_ID (Invoice)
				@InvoiceID, -- RecordID (reference)
				NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);
		END

		--If there's payment, we need to refund these payments to account credits
		IF(Select newRefundPaymentID from #doublePost WHERE RowID = @RowCount) is not NULL
		BEGIN
			SET @RowAffected = @RowAffected + 1
			DECLARE @Pymt_original uniqueidentifier = (select PaymentID from #doublePost where RowID = @RowCount)
			DECLARE @CreditHistoryID uniqueidentifier = (select newCreditHistoryID from #doublePost where RowID = @RowCount)
			DECLARE @LocationID uniqueidentifier = (select locationid from Custom.Invoice where ID = @InvoiceID)
			--set the batchID as the journalbatchID that has this paymentID
			DECLARE @JournalBatchID int = (select min(JournalBatchId) from custom.GLJournal where InvoiceId = @InvoiceID)

			SET @PYRecordName = @PYRecordName + 1
			INSERT INTO [Custom].[Payment]
			   ([ID]
			   ,[RecordName]
			   ,[LocationId]
			   ,[CreatedDate]
			   ,[CreatedByUserID]
			   ,[ModifiedDate]
			   ,[ModifiedByUserID]
			   ,[Status]
			   ,[Amount]
			   ,[PaymentType]
			   ,[PaymentMethod]
			   ,[PaymentStatus]
			   ,[Type]
			   ,[PaymentReturned]
			   ,[Invoice]
			   ,[Details]
			   ,[RefundPaymentId]
			   ,[OriginalPaymentId]
			   ,[ContactID]
			   )
			SELECT
			   d.newRefundPaymentID
			   ,'PYMTFIX-' + RIGHT('00000' + CAST(@PYRecordName as varchar(20)), 5)
			   ,i.LocationId
			   ,@BackDate
			   ,@DatafixUserID
			   ,@UTCNow
			   ,@DatafixUserID
			   ,0 --status
			   ,d.toBeRefundAmount *-1 --amount
			   ,3 --payment type
			   ,8 --payment method
			   ,0 --payment status
			   ,1 --type
			   ,0 --payment returned
			   ,d.InvoiceID
			   ,'PM Support (PMDEV-XXXXXX): refund to account credit'
			   ,d.PaymentID -- refund payment ID
			   ,d.PaymentID -- original payment ID
			   ,i.ContactId -- contact ID
			 From #doublePost d
			 left join Custom.Invoice i on i.ID = d.InvoiceID
			 where d.RowID = @RowCount

			INSERT INTO Custom.DataChange
				(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
				 Select
					@Pay_ObjectID, -- Object_ID (Payment)
					d.newRefundPaymentID, -- RecordID (reference)
					NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/
				 from #doublePost d
				 where RowID = @RowCount

		-- Update as refunded

			UPDATE Custom.Payment
				SET Status = 6, PaymentStatus = 0, PaymentReturned = 1
					,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
				WHERE ID = @Pymt_original;

			delete from Custom.DataChange where RecordID = @Pymt_original
			INSERT INTO Custom.DataChange
				(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
				VALUES (
					@Pay_ObjectID, -- Object_ID (Payment)
					@Pymt_original, -- RecordID (reference)
					NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

		-- Credit history record
			SET @CRRecordName = @CRRecordName + 1
			INSERT INTO [Custom].[CreditHistory]
				   ([ID]
				   ,[RecordName]
				   ,[LocationId]
			   ,[CreatedDate]
			   ,[CreatedByUserID]
			   ,[ModifiedDate]
			   ,[ModifiedByUserID]
			   ,[Amount]
			   ,[Reason]
			   ,[Transaction]
			   ,[PaymentId]
			   ,[Contact]
			   ,[Notes]
			   )
			Select
			   newCreditHistoryID
			   ,'CRFIX-' + RIGHT('00000' + CAST(@CRRecordName as varchar(20)), 5) -- record name
			   ,i.LocationId
			   ,@BackDate
			   ,@DatafixUserID
			   ,@UTCNow
			   ,@DatafixUserID
			   ,toBeRefundAmount
			   ,'Refund as Credit'
			   ,i.TransactionID
			   ,newRefundPaymentID
			   ,i.ContactId
			   ,'Amend Credit - PM Support (PMDEV-XXXXXX)'
			from #doublePost
			left join Custom.Invoice i on i.ID = InvoiceID
			where rowid = @rowcount

			SET @GLRecordName = @GLRecordName + 1		
			INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
			SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@GLRecordName as varchar(20)), 6), i.LocationId, @DatafixUserID, @DatafixUserID, 0, d.toBeRefundAmount, 'Account Credit, PMFIX for PMDEV-XXXXXX', j1.GLAccountName, j1.GLNumber, @CreditHistoryID, '368DB42A-D126-4E1F-B983-5643C2330A77', j1.GLAccountID, i.TransactionID, ch.CreatedDate, @InvoiceID, @JournalBatchId, 'None'
			FROM Custom.CreditHistory ch
				left join 
				(select top 1 * from Custom.GLJournal j where j.Reference_ObjectID = '368DB42A-D126-4E1F-B983-5643C2330A77' and j.LocationId = @LocationID Order by j.EffectiveDate desc) j1
				on ch.LocationId = j1.LocationId
				left join #doublePost d on d.newCreditHistoryID = ch.ID
				left join Custom.Invoice i on i.ID = d.InvoiceID
			WHERE ch.ID = @CreditHistoryID

		END
		
		SET @RowCount = @RowCount +1

	END

	--Update Transaction as Failed
	IF @Rule43 =1
	BEGIN
		DECLARE @Txn uniqueidentifier = (select min(transactionID) from #doublePost)
		UPDATE Custom.[Transaction]	
			SET Status = 4, TransactionStatus = 4, RemainingBalance = '0', DelinquentAmount = '0',
				Notes = 'PM Support (PMDEV-XXXXXX). Update transaction as failed for fail safe issue'
				,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
			WHERE ID = @Txn;
		INSERT INTO Custom.DataChange
			(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
			VALUES (
				@Txn_ObjectID, -- Object_ID (Transaction)
				@Txn, -- RecordID (reference)
				NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

	END

	IF @RowAffected = 0
	BEGIN
		select 'All invoices entered have been refunded/forfeited/completed. Please check if clients have fixed it already.' as WARNING
		set @dryrun =1
	END


	IF @DryRun = 1 BEGIN
		ROLLBACK TRANSACTION @TxnName;
		RAISERROR ('DryRun was enabled. No changes were committed', 11, 1);
	END ELSE BEGIN
		COMMIT TRANSACTION @TxnName;
	END
END
