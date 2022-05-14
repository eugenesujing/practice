/*
PMDEV-167505
Add new subsidy history for transaction 393012
*/
use G423782;

DECLARE @DryRun bit = 0; -- If 1, rolls back the transaction afterward.
DECLARE @TxnName varchar(32) = 'PMDEV-167505'

--select newid()
--select * from custom.subsidyhistory s where s.recordname like 'SHFIX%' order by recordname

BEGIN
	IF @DryRun = 1 BEGIN
		RAISERROR ('DryRun is enabled. No changes will be committed', 11, 1);
	END
	BEGIN TRANSACTION @TxnName;
	
	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();

	DECLARE @Backdate datetime = @UTCNow;
	DECLARE @Sub1 uniqueidentifier = '0371E254-C1D0-4A19-BD83-31871B353B02';
	DECLARE @Sub2 uniqueidentifier = '9E789D46-934C-4659-AB34-A3BBF992902E';




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
	           (@Sub1 
	           ,@Backdate
	           ,@DatafixUserID
	           ,@UTCNow
	           ,@DatafixUserID
	           ,'76089D39-7519-4B0B-A7BE-2C949F17A878' -- SubsidyAllocationId
	           ,'02B01BA6-C775-4F25-B343-056380E6ADD5' -- CartItemId
	           ,'A340ED95-1F56-476A-A1F0-E65026C84442' -- PaymentId
	           ,'8A1B3F99-8AF3-41DD-BD1D-E1FBB516F1A9' -- TransactionID
	           ,'4.42' -- Amount
	           ,'2' -- Type 1 = payment, 2 = refund
	           ,'1'
	           ,'SHFIX-00039')

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
	           (@Sub2 
	           ,@Backdate
	           ,@DatafixUserID
	           ,@UTCNow
	           ,@DatafixUserID
	           ,'D954E00A-481B-4D0B-97C0-5991B9D7ACC7' -- SubsidyAllocationId
	           ,'D4985716-ED9E-487F-8BDF-DCA88C38D063' -- CartItemId
	           ,'352DDC55-6D0D-4F22-B60A-5D5B0B169A5C' -- PaymentId
	           ,'8A1B3F99-8AF3-41DD-BD1D-E1FBB516F1A9' -- TransactionID
	           ,'4.42' -- Amount
	           ,'2' -- Type 1 = payment, 2 = refund
	           ,'1'
	           ,'SHFIX-00040')


	

	IF @DryRun = 1 BEGIN
		ROLLBACK TRANSACTION @TxnName;
		RAISERROR ('DryRun was enabled. No changes were committed', 11, 1);
	END ELSE BEGIN
		COMMIT TRANSACTION @TxnName;
	END
END
