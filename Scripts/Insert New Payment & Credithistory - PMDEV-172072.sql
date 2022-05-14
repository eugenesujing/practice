/*
PMDEV-162958
Refund PYMT-150861 to account credit.
*/
use G423782;

DECLARE @DryRun bit = 0; -- If 1, rolls back the transaction afterward.
DECLARE @TxnName varchar(32) = 'PMDEV-172072'

BEGIN
    BEGIN TRANSACTION @TxnName;

	--select newid();
	--select * from custom.payment p where p.RecordName like 'PYMTFIX%' ORDER BY RECORDNAME DESC
	--select * from custom.credithistory c where c.recordname like 'CRFIX-%' ORDER BY RECORDNAME DESC
    
    DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
    DECLARE @UTCNow datetime = GETUTCDATE();
	DECLARE @BackDate datetime = '2022-01-28 19:52:05.920';

	DECLARE @Txn uniqueidentifier = '39AEC5A5-4F6C-492C-B5D7-701FD8463770';
	DECLARE @Loc uniqueidentifier = '7DFE1A3D-3D03-407A-9EF5-D44CCC664C63';
	DECLARE @Contact uniqueidentifier = 'B797AE5F-3F9F-4FF6-A826-2B7AEB9E8268';

	DECLARE @Inv1 uniqueidentifier = '61D57662-2ED2-41A7-AD9E-8561EA778EF9';
	DECLARE @Pymt_original1 uniqueidentifier = '78EEC967-4E23-43FD-B480-4902187E9F98';


	--select newid();
	DECLARE @CreditHistoryID1 uniqueidentifier = 'F2416663-A8E9-4E8C-A890-5DCA89B0760C';
	DECLARE @PaymentID1 uniqueidentifier = '600D5543-B4C8-4140-A3EB-405040E21DA8';


	DECLARE @Txn_ObjectID uniqueidentifier = '835E2315-51D5-46F5-A260-236E858A7534';
	DECLARE @Inv_ObjectID uniqueidentifier = 'F9822D6C-31ED-41D2-81C7-F8E8DE242E79';
	DECLARE @Pay_ObjectID uniqueidentifier = '67F02CDA-018F-4F1D-ABC0-960ED27F9006';

	-- refund PYMT-150861 to account credit

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
     VALUES
           (@PaymentID1
           ,'PYMTFIX-00001'
           ,@Loc
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,-3.1 --amount
           ,3 --payment type
           ,8 --payment method
           ,0 --payment status
           ,1 --type
           ,0 --payment returned
           ,@Inv1
		   ,'PM Support (PMDEV-172072): refund PYMT-206310 to account credit'
		   ,@Pymt_original1 -- refundpayment ID
		   ,@Pymt_original1 -- original payment ID
		   ,@Contact -- contact ID
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@PaymentID1, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

	-- Update PYMT-150861 as refunded

	UPDATE Custom.Payment
		SET Status = 6, PaymentStatus = 0, PaymentReturned = 1
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Pymt_original1;

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@Pymt_original1, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

	-- Credit history record

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
     VALUES
           (@CreditHistoryID1
           ,'CRFIX-00001' -- record name
           ,@Loc
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,3.1
           ,'Refund as Credit'
           ,@Txn
           ,@PaymentID1
		   ,@Contact
		   ,'FA-6088 Amend Credit - PM Support (PMDEV-172072)'
		   )


    IF @DryRun = 1 BEGIN
        ROLLBACK TRANSACTION @TxnName;
    END ELSE BEGIN
        COMMIT TRANSACTION @TxnName;
    END
END
