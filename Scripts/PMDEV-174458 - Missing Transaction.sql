/*
PMDEV-174458
Missing transaction on PM.

What this script does:
	1. Update the Custom.Payment/Invoice/Transaction/GLJournal tables according to the information provided by client.

What you need to update:
	1.Update the DB number.
	2.Update the PMDEV- number.
	3.Update the @BackDate according to the CreateDate shown on Custom.DeviceTransaction
	4.Update the @Effective to @BackDate/@CurrentDate
	5.Update the information listed for Payment Table (approval code, details, PaymentMethod, devicetransactionid, TransactionID = UniqueTransactionID from DeviceTransaction)
	6.After creating the transaction on UI, update the transaction RecordName
	7.If the paymentMethod is credit card, uncomment the update for ReferenceDescription

*/
use G424063;

DECLARE @DryRun bit = 0; -- If 1, rolls back the transaction afterward.
DECLARE @TxnName varchar(32) = 'PMDEV-174458'

BEGIN
	IF @DryRun = 1 BEGIN
		RAISERROR ('DryRun is enabled. No changes will be committed', 11, 1);
	END
	BEGIN TRANSACTION @TxnName;
	
	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();
	DECLARE @BackDate datetime = '2022-03-04 19:33:29.190';
	DECLARE @Currentdate datetime = GETUTCDATE();
	--Update @EffectiveDate according to the requirement
	DECLARE @EffectiveDate datetime = @BackDate;

	DECLARE @TransactionID uniqueidentifier 
	DECLARE @InvoiceID uniqueidentifier 
	DECLARE @PaymentID uniqueidentifier 

	Select @TransactionID = t.ID,  @InvoiceID = i.ID, @PaymentID = p.ID 
	from Custom.[Transaction] t
	left join Custom.Invoice i on i.TransactionID = t.ID
	left join Custom.Payment p on p.invoice = i.ID
	WHERE t.recordname = '703149'

	-- Update Payment with the approval code, details, PaymentMethod, devicetransactionid, TransactionID = UniqueTransactionID from DeviceTransaction
	UPDATE Custom.Payment
		SET CreatedDate = @EffectiveDate, SettlementDate = @EffectiveDate,
			Details = '************5592', PaymentType = 1, PaymentMethod = 4/*1 = creditCard, 3 = Check, 4 = Debit*/, ApprovalCode = '001327',
			TransactionID = '0010018220', Processor = 2, ManualEntry = 1,
			DeviceTransactionID = '993F37AB-F8E7-423A-9DD4-807150D03D11',
			ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID, CreatedByUserID = @DatafixUserID
		WHERE ID = @PaymentID;
    INSERT INTO [Custom].[DataChange] ([Object_ID],[RecordID],[TransactionID],[Status],[ModifiedDate])SELECT
            '67F02CDA-018F-4F1D-ABC0-960ED27F9006' --  pay_obj
            ,@PaymentID -- pay_id
            ,NULL
            ,2 -- Modifying
            ,GETUTCDATE();-- always use GETUTCDATE()


	UPDATE Custom.[Transaction]
		SET FirstPayment = @EffectiveDate, FinalPayment = @EffectiveDate, CreatedDate = @EffectiveDate, Processor = 2,
		ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID, CreatedByUserID = @DatafixUserID
		WHERE ID = @TransactionID;
    INSERT INTO [Custom].[DataChange] ([Object_ID],[RecordID],[TransactionID],[Status],[ModifiedDate])SELECT
            '6DF3313E-2AD6-4CBE-981F-AA2DCE92DD43' --  txn_obj
            ,@TransactionID -- txn_id
            ,NULL
            ,2 -- Modifying
            ,GETUTCDATE();-- always use GETUTCDATE()


	UPDATE Custom.[Invoice]
		SET InvoiceDueDate = @EffectiveDate, CreatedDate = @EffectiveDate, Processor = 2, 
		ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID, CreatedByUserID = @DatafixUserID
		WHERE ID = @InvoiceID;
    INSERT INTO [Custom].[DataChange] ([Object_ID],[RecordID],[TransactionID],[Status],[ModifiedDate])SELECT
            '8D2C4E84-FFBD-44B9-99CE-3B90895B64F6' --  inv_obj
            ,@InvoiceID -- inv_id
            ,NULL
            ,2 -- Modifying
            ,GETUTCDATE();-- always use GETUTCDATE()

	-- If credit card, update the GL journal reference desc
	--UPDATE Custom.GLJournal SET ReferenceDescription = 'CreditCard' WHERE Reference = @PaymentID and TransactionID = @TransactionID

	UPDATE Custom.GLJournal
		SET EffectiveDate = @EffectiveDate, CreatedDate = @UTCNow,
			ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID, CreatedByUserID = @DatafixUserID,
			ReferenceDescription =  ReferenceDescription + ', DATAFIX FOR PMDEV-174458 : Create Missing Transaction'
		WHERE TransactionID = @TransactionID and EffectiveDate < @UTCNow


	IF @DryRun = 1 BEGIN
		ROLLBACK TRANSACTION @TxnName;
		RAISERROR ('DryRun was enabled. No changes were committed', 11, 1);
	END ELSE BEGIN
		COMMIT TRANSACTION @TxnName;
	END
END