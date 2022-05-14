/*
PMDEV-174586
Fail invoices 9138, 47932, 47933, 47977, 47978 and insert forfeit payments, update invoices as past amendment.
Refund PYMT-10066 to account credit.
*/
use G423782;

DECLARE @DryRun bit = 0; -- If 1, rolls back the transaction afterward.
DECLARE @TxnName varchar(32) = 'PMDEV-174586'

	--select newid();
	--select * from custom.payment p where p.RecordName like 'PYMTFIX%' ORDER BY RECORDNAME DESC
	--select * from custom.credithistory c where c.recordname like 'CRFIX-%'

BEGIN
    BEGIN TRANSACTION @TxnName;
    
    DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @BackDate datetime = '2022-03-14 15:03:44.947'
    DECLARE @UTCNow datetime = GETUTCDATE();

	DECLARE @Txn uniqueidentifier = 'E1F75646-4C22-4E37-91FA-44103DFFA001';
	DECLARE @Loc uniqueidentifier = 'D3AF60C7-1A08-4301-83C1-007B4AA8D0FB';
	DECLARE @Contact uniqueidentifier = 'B962D0B5-B29B-4C0E-9E54-D0F287F7E4E7';

	DECLARE @Inv1 uniqueidentifier = 'AD0DBA44-8243-41D4-B537-3954E59B1513';
	DECLARE @Inv2 uniqueidentifier = '043B3FA2-EB86-42EE-B66E-229A477EA5FE';
	DECLARE @Inv3 uniqueidentifier = 'D71F6795-3B43-4E5F-9A8F-FEAB3B053892';
	/*DECLARE @Inv4 uniqueidentifier = '17C6F692-8F4D-4CCE-BE50-3436FAC3331B';
	DECLARE @Inv5 uniqueidentifier = 'AEA893E3-4019-4A14-B1ED-D488AD8D7481';
	DECLARE @Inv6 uniqueidentifier = 'A740090E-BBA0-4878-AFE4-BE5B984470D1';
	DECLARE @Inv7 uniqueidentifier = '1FBD3CC4-2832-4A85-9C54-334B6CC7143B';*/

	DECLARE @Pymt_original1 uniqueidentifier = '2ACC2C89-BD9C-4ECD-8CC2-0BB914CA4BE9';
	DECLARE @Pymt_original2 uniqueidentifier = 'EE737A3C-B8AA-47A8-8331-9A2566FF7329';
	--select newid();
	--DECLARE @ForfeitPayment1 uniqueidentifier = '5BEC4378-BE72-4DFB-929D-A5D753B7ED45';
	DECLARE @ForfeitPayment2 uniqueidentifier = 'B21519BC-A77C-4A0F-8167-2ABB910D91CA';
	DECLARE @ForfeitPayment3 uniqueidentifier = '55742984-5BCA-4D6F-82B9-50BB7E301A9D';
	/*DECLARE @ForfeitPayment4 uniqueidentifier = 'E6BCB70D-B6A1-4077-9627-0BAD815326E8';
	DECLARE @ForfeitPayment5 uniqueidentifier = '375DF94D-D150-44DF-85CA-848232EB3FB0';
	DECLARE @ForfeitPayment6 uniqueidentifier = 'F241F635-45EE-40EB-9BDC-A5CD027A2F8A';
	DECLARE @ForfeitPayment7 uniqueidentifier = '773D619F-2E10-4622-B6C7-EE2298A417F6';*/

	DECLARE @CreditHistoryID1 uniqueidentifier = '2686732D-848F-47AB-BCE9-05F1B508312D';
	DECLARE @PaymentID1 uniqueidentifier = 'F77AEF91-BF8D-42F7-B38C-2C4285AE5984';
	DECLARE @CreditHistoryID2 uniqueidentifier = '9D27C7F2-C16E-49C4-8519-87C5379330E5';
	DECLARE @PaymentID2 uniqueidentifier = '13EE9A7C-4EFE-4DCA-B5FD-E9ADC5719774';

	DECLARE @Txn_ObjectID uniqueidentifier = '835E2315-51D5-46F5-A260-236E858A7534';
	DECLARE @Inv_ObjectID uniqueidentifier = 'F9822D6C-31ED-41D2-81C7-F8E8DE242E79';
	DECLARE @Pay_ObjectID uniqueidentifier = '67F02CDA-018F-4F1D-ABC0-960ED27F9006';

	-- Insert forfeit payment records
	 
	/*INSERT INTO [Custom].[Payment]
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
           ,'PYMTFIX-00001'
           ,@Loc -- location ID
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,1024.55 --amount
           ,1 --payment type
           ,-1 --payment method
           ,0 --payment status
           ,3 --type
           ,0 --payment returned
           ,@Inv1
		   ,'PM Support (PMDEV-174586): fix facility contract amendment'
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@ForfeitPayment1, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);*/

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
           (@ForfeitPayment2
           ,'PYMTFIX-00004'
           ,@Loc -- location ID
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,16128.33 --amount
           ,1 --payment type
           ,-1 --payment method
           ,0 --payment status
           ,3 --type
           ,0 --payment returned
           ,@Inv2
		   ,'PM Support (PMDEV-174586): fix facility contract amendment'
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@ForfeitPayment2, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

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
           (@ForfeitPayment3
           ,'PYMTFIX-00005'
           ,@Loc -- location ID
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,18992.41 --amount
           ,1 --payment type
           ,-1 --payment method
           ,0 --payment status
           ,3 --type
           ,0 --payment returned
           ,@Inv3
		   ,'PM Support (PMDEV-174586): fix facility contract amendment'
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@ForfeitPayment3, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

	/*INSERT INTO [Custom].[Payment]
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
           (@ForfeitPayment4
           ,'PYMTFIX-00004'
           ,@Loc -- location ID
           ,@@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,8977.80 --amount
           ,1 --payment type
           ,-1 --payment method
           ,0 --payment status
           ,3 --type
           ,0 --payment returned
           ,@Inv4
		   ,'PM Support (PMDEV-174586): fix facility contract amendment'
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@ForfeitPayment4, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

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
           (@ForfeitPayment5
           ,'PYMTFIX-00005'
           ,@Loc -- location ID
           ,@@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,13691.21 --amount
           ,1 --payment type
           ,-1 --payment method
           ,0 --payment status
           ,3 --type
           ,0 --payment returned
           ,@Inv5
		   ,'PM Support (PMDEV-174586): fix facility contract amendment'
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@ForfeitPayment5, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

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
           (@ForfeitPayment6
           ,'PYMTFIX-00006'
           ,@Loc -- location ID
           ,@@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,13354.51 --amount
           ,1 --payment type
           ,-1 --payment method
           ,0 --payment status
           ,3 --type
           ,0 --payment returned
           ,@Inv6
		   ,'PM Support (PMDEV-174586): fix facility contract amendment'
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@ForfeitPayment6, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

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
           (@ForfeitPayment7
           ,'PYMTFIX-00007'
           ,@Loc -- location ID
           ,@@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,14013.87 --amount
           ,1 --payment type
           ,-1 --payment method
           ,0 --payment status
           ,3 --type
           ,0 --payment returned
           ,@Inv7
		   ,'PM Support (PMDEV-174586): fix facility contract amendment'
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@ForfeitPayment7, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);*/

	-- Forfeit invoices and update as past amendment

	/*UPDATE Custom.Invoice	
		SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '1024.55'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv1;*/

	UPDATE Custom.Invoice	
		SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '16128.33'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv2;

	UPDATE Custom.Invoice	
		SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '18992.41'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv3;

	/*UPDATE Custom.Invoice	
		SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '8977.80'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv4;

	UPDATE Custom.Invoice	
		SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '13691.21'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv5;

	UPDATE Custom.Invoice	
		SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '13354.51'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv6;

	UPDATE Custom.Invoice	
		SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', DelinquentAmount = '0', ForfeitedAmount = '14013.87'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv7;*/

	UPDATE Custom.Invoice	
		SET PastAmendment = 1
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID IN (@Inv1, @Inv2, @Inv3/*, @Inv4, @Inv5,@Inv6,@Inv7*/);

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv1, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv2, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv3, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

	/*INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv4, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv5, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv6, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv7, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);
	*/
	
	-- refund PYMT-10066 to account credit

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
           ,'PYMTFIX-00006'
           ,@Loc
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,-43554.70 --amount
           ,3 --payment type
           ,8 --payment method
           ,0 --payment status
           ,1 --type
           ,0 --payment returned
           ,@Inv1
		   ,'PM Support (PMDEV-174586): refund PYMT-461361 to account credit'
		   ,@Pymt_original1 -- refund payment ID
		   ,@Pymt_original1 -- original payment ID
		   ,@Contact -- contact ID
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@PaymentID1, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

	-- Update PYMT-10066 as refunded

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
           ,'CRFIX-00004' -- record name
           ,@Loc
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,43554.70
           ,'Refund as Credit'
           ,@Txn
           ,@PaymentID1
		   ,@Contact
		   ,'FA-5616 Amend Credit - PM Support (PMDEV-174586)'
		   )

		   
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
           (@PaymentID2
           ,'PYMTFIX-00007'
           ,@Loc
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,0 --status
           ,-307.40 --amount
           ,3 --payment type
           ,8 --payment method
           ,0 --payment status
           ,1 --type
           ,0 --payment returned
           ,@Inv2
		   ,'PM Support (PMDEV-174586): refund PYMT-461364 to account credit'
		   ,@Pymt_original2 -- refund payment ID
		   ,@Pymt_original2 -- original payment ID
		   ,@Contact -- contact ID
           )

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@PaymentID2, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 1, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

	-- Update PYMT-10066 as refunded

	UPDATE Custom.Payment
		SET Status = 6, PaymentStatus = 0, PaymentReturned = 1
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Pymt_original2;

	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@Pymt_original2, -- RecordID (reference)
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
           (@CreditHistoryID2
           ,'CRFIX-00005' -- record name
           ,@Loc
           ,@BackDate
           ,@DatafixUserID
           ,@UTCNow
           ,@DatafixUserID
           ,307.40
           ,'Refund as Credit'
           ,@Txn
           ,@PaymentID2
		   ,@Contact
		   ,'FA-5616 Amend Credit - PM Support (PMDEV-174586)'
		   )

    IF @DryRun = 1 BEGIN
        ROLLBACK TRANSACTION @TxnName;
    END ELSE BEGIN
        COMMIT TRANSACTION @TxnName;
    END
END
