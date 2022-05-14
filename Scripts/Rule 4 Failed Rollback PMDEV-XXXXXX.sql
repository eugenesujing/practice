/*
PMDEV-XXXXXX
Failed transaction + invoice rollback resulting in no payment and no GLs. Failing both the transaction and invoice.
If there's payment, fail the payment.

1. Change the PMDEV number.
2. Change the DB number.
3. Change the transaction record name.
4. Execute.
5. Double check for transactions and invoices.

*/
use G42XXXX;


DECLARE @DryRun bit = 0; -- If 1, rolls back the transaction afterward.
DECLARE @TxnName varchar(32) = 'PMDEV-XXXXXX'

	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();
	DECLARE @Txn_ObjectID uniqueidentifier = '835E2315-51D5-46F5-A260-236E858A7534'
	DECLARE @Inv_ObjectID uniqueidentifier = 'F9822D6C-31ED-41D2-81C7-F8E8DE242E79'
	DECLARE @Pay_ObjectID uniqueidentifier = '67F02CDA-018F-4F1D-ABC0-960ED27F9006';
	
	drop table if exists #rule4

	--retrieve data about the transaction record that is failed rollback rule 4
	select ROW_NUMBER() OVER( ORDER BY p.createddate) RowID, t.id as TransactionID, 
	i.id as InvoiceID, i.amount as InvoiceAmount, p.id as PaymentID, t.totalamount as TxnAmount,
	CASE WHEN p.amount is null THEN 0 ELSE p.amount END as PaymentAmount
	into #rule4
	from Custom.[Transaction] t
	left join Custom.Invoice i on i.transactionid = t.id
	left join Custom.Payment p on p.invoice = i.id
	--change the transaction recordname
	where t.RecordName in ('424107', '422647')
	--and i.RemainingBalance <> (i.amount - CASE WHEN p.amount is null THEN 0 ELSE p.amount END)
	--select * from #rule4

	DECLARE @NumberRecords int
	DECLARE @RowCount int

	SELECT @NumberRecords = max (RowID) from #rule4 
	SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
	IF @DryRun = 1 BEGIN
		RAISERROR ('DryRun is enabled. No changes will be committed', 11, 1);
	END
	BEGIN TRANSACTION @TxnName;
	


	DECLARE @Txn uniqueidentifier;
	DECLARE @Inv uniqueidentifier;
	DECLARE @InvAmt Decimal(20,2);
	DECLARE @PayAmt Decimal(20,2);
	DECLARE @TxnAmt Decimal(20,2);
	DECLARE @Payment uniqueidentifier;

	Select @Txn = r.TransactionID, @Inv = r.InvoiceID, @InvAmt = r.InvoiceAmount, 
	@PayAmt = r.PaymentAmount, @Payment = r.PaymentID, @TxnAmt = r.TxnAmount
	From #rule4 r
	Where r.RowID = @RowCount

	delete from custom.DataChange
	where RecordID in (@Txn, @Inv) and Status = 2
	
	UPDATE Custom.[Transaction]	
		SET Status = 4, TransactionStatus = 4, RemainingBalance = '0',
			Notes = 'PM Support ' + @TxnName + ' : Member-created transaction failed to rollback upon failed payment. This transaction and its invoice will be marked as terminated.'
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID, ForfeitedAmount = @TxnAmt
		WHERE ID = @Txn;
	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Txn_ObjectID, -- Object_ID (Transaction)
			@Txn, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);

	if @Inv is not null
	begin
	UPDATE Custom.Invoice	
		SET Status = 4, InvoiceStatus = 4, RemainingBalance = '0', ForfeitedAmount = @InvAmt 
			,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Inv;
	INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Inv_ObjectID, -- Object_ID (Invoice)
			@Inv, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ GETUTCDATE() /* ModifiedDate (leave as GETUTCDATE()) */);
	
	end
	--If there's payment, then update payment as failed
	IF @PayAmt <> 0
	BEGIN
		UPDATE Custom.Payment
		SET Status = 4, PaymentStatus = 4
		,ModifiedDate = @UTCNow, ModifiedByUserID = @DatafixUserID
		WHERE ID = @Payment

		INSERT INTO Custom.DataChange
		(Object_ID, RecordID, TransactionID, Status, ModifiedDate)
		VALUES (
			@Pay_ObjectID, -- Object_ID (Payment)
			@Payment, -- RecordID (reference)
			NULL, /* TransactionID (leave as null) */ 2, /* Status, 1 = insert, 2 = modify */ @UTCNow /* ModifiedDate*/);

	END

	-- Delete attendance records

	DELETE
		FROM Custom.Attendance
		WHERE PaidTransactionID = @Txn;

	IF @DryRun = 1 BEGIN
		ROLLBACK TRANSACTION @TxnName;
		RAISERROR ('DryRun was enabled. No changes were committed', 11, 1);
	END ELSE BEGIN
		COMMIT TRANSACTION @TxnName;
	END

	SET @RowCount = @RowCount + 1
END
