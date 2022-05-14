/*Forfeit a payment and update invoice and transaction status*/

use G424415;

DECLARE @DryRun bit = 0; -- If 1, rolls back the transaction afterward.
DECLARE @TxnName varchar(32) = 'PMDEV-171702'

	--select newid();
	--select * from custom.payment p where p.RecordName like 'PYMTFIX%' ORDER BY RECORDNAME
	--select * from custom.credithistory c where c.recordname like 'CRFIX-%'

BEGIN
    BEGIN TRANSACTION @TxnName;
    
    DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
    DECLARE @UTCNow datetime = '2022-01-21 18:40:52.500';

	
	DECLARE @Loc uniqueidentifier = 'B368FC7E-B9C1-497E-A9B1-A0DD131C8EDF';
	DECLARE @Contact uniqueidentifier = '0D0C470C-22CF-4206-8323-5C36EC4AAFDE';

	DECLARE @Txn1 uniqueidentifier = '1DD52DA7-5804-42B8-94FE-D7A00AE7D869';


	DECLARE @Inv1 uniqueidentifier = '0D70D446-C04F-417D-8A3A-1517FB473E52';



	--DECLARE @Pymt10066 uniqueidentifier = '5873FA28-1B35-4373-B9E6-67E3F9062C1A';
	--select newid();
	DECLARE @ForfeitPayment1 uniqueidentifier = 'BB4CF6C4-EC90-4181-86FF-E2912274A280';



	--DECLARE @CreditHistoryID uniqueidentifier = '9D02DDEB-1311-466E-B656-9F0ACD1137DF';
	--DECLARE @PaymentID uniqueidentifier = 'DBA059A6-89BB-478C-ABE3-E68B243C01B1';

	DECLARE @Txn_ObjectID uniqueidentifier = '835E2315-51D5-46F5-A260-236E858A7534';
	DECLARE @Inv_ObjectID uniqueidentifier = 'F9822D6C-31ED-41D2-81C7-F8E8DE242E79';
	DECLARE @Pay_ObjectID uniqueidentifier = '67F02CDA-018F-4F1D-ABC0-960ED27F9006';


--insert forfeit payment

--Invoice 1

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
     VALUES
           (@ForfeitPayment1
           ,'PYMTFIX-00074'
           ,@Loc -- location ID
           ,@UTCNow
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,600.00 --amount
           ,1 --payment type
           ,-1 --payment method
           ,0 --payment status
           ,3 --type
           ,0 --payment returned
           ,@Inv1
		   ,'PM Support (PMDEV-171702): forfeit remaining balance'
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@ForfeitPayment1, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

	UPDATE Custom.Invoice	
		SET Status=4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '600.00'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv1;

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv1, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);
	
	UPDATE Custom.[Transaction]	
		SET Status=4, TransactionStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '14973.60'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Txn1;
	
	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Txn_ObjectID, -- Object_ID (Invoice)
			@Txn1, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

    IF @DryRun = 1 BEGIN
        ROLLBACK TRANSACTION @TxnName;
    END ELSE BEGIN
        COMMIT TRANSACTION @TxnName;
    END
END
