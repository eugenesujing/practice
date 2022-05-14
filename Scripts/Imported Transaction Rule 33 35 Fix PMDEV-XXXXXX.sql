/*
Author: Jing Su
Created Date: 2022-04-06
Modified Date: 2022-04-06

PMDEV-XXXXXX

What this script does:
	It's a generic fix for rule 33/35 for imported transactions, and it will insert the following 3 records to Custom.GLJournal

	1.Insert payment GL for the refund payment/account credit
	2.Insert GL for returned tax
	3.Insert GL for returned cartitems

What you should do:
	1.Change the DB number
	2.Change the PMDEV number
	4.Change the Payment record name
	6.Execute and double check the results
	
*/

--PMDEV-XXXXXX
use G42XXXX;
	--delete from custom.gljournal where referencedescription like '%PMFIX for PMDEV-XXXXXX'
	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();
	
	drop table if exists #import

	select ROW_NUMBER() OVER( ORDER BY p.createddate) RowID,
	i.id as InvoiceID, p.ID as PaymentID, i.TransactionID, p.LocationId, i.ContactId, p.Amount,
	p.CreatedDate /*If payment method is 1,2,4, effectivedate should be settlement date, otherwise created date*/
	into #import
	from Custom.Invoice i
	left join Custom.Payment p on p.invoice = i.id
	--change the payment recordname
	where p.RecordName in ('PYMT-381855')

	DECLARE @PaymentID Uniqueidentifier
	DECLARE @InvoiceID Uniqueidentifier
	DECLARE @ContactID Uniqueidentifier
	DECLARE @TransactionID Uniqueidentifier
	DECLARE @LocationID Uniqueidentifier
	DECLARE @EffectiveDate datetime
	DECLARE @NumberRecords int
	DECLARE @RowCount int
	DECLARE @PaymentAmount decimal(20,2)

	SELECT @NumberRecords = max (RowID) from #import
	SET @RowCount = 1

	DECLARE @RecordName int
    SELECT @RecordName = MAX(CAST(SUBSTRING(RecordName, 7, 6) AS int)) FROM Custom.GLJournal
    WHERE RecordName LIKE 'GLFIX-[0-9]%'
    IF @RecordName IS NULL SET @RecordName = 0

	
WHILE @RowCount <= @NumberRecords
BEGIN
	DECLARE @JournalBatchId int
	SELECT @JournalBatchId =  max(JournalBatchId) from Custom.GLJournal
	SET @JournalBatchId = ISNULL(@JournalBatchId, 0) + 1



	SELECT @PaymentID = PaymentID, @InvoiceID= InvoiceID, @ContactID = ContactID, @PaymentAmount = Amount*-1,
	@TransactionID = TransactionID, @LocationID = LocationID, @EffectiveDate = CreatedDate
	FROM #import
	WHERE RowID = @RowCount

	--calculate the revenue refunded and tax refunded
	DECLARE @Price decimal(20,2) = (select price from custom.cartitem where transactionID = @TransactionID)
	DECLARE @RefundedRevenue decimal(20,2)
	select @RefundedRevenue = @Price * MM.SessionsLeft/mm.SessionsPurchased from custom.[transaction] t
	left join custom.cartitem ci on ci.transactionid = t.id
	left join custom.MembershipMember MM on MM.CartItemId = CI.ID
	where t.id = @TransactionID

	DECLARE @RefundedTax decimal(20,2) = @PaymentAmount - @RefundedRevenue

	/*If payment method is 1,2,4, effectivedate should be settlement date, otherwise created date*/

	if (select paymentmethod from Custom.Payment where id = @PaymentID) in (1, 2 ,4 )
	Begin
		Select @EffectiveDate = p.settlementdate
		from Custom.Payment p
		Where p.id = @PaymentID
	End

		
		if (select paymentmethod from Custom.Payment where id = @PaymentID) <> 8
		Begin
		-- [Custom].[GLJournal] for Payment	
			SET @RecordName = @RecordName + 1	
			INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
			SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), p.LocationId, @DatafixUserID, @DatafixUserID, 0, @PaymentAmount, 'refund on imported transaction, PMFIX for PMDEV-XXXXXX', it.RecordName, it.GLNumber, p.id, '67F02CDA-018F-4F1D-ABC0-960ED27F9006', it.ID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchId, 'None'
			FROM Custom.payment p
				join Custom.GLAccountAssignment glass on glass.Reference = (select referenceid from custom.paymentmethod where id =  p.paymentmethod) and glass.EffectiveEndDate IS NULL
				join Custom.IncomeType it on glass.GLAccountId = it.ID
			WHERE p.ID = @PaymentID and it.IsSystem =1
			OPTION (MAXDOP 1);
		END

		--if the payment method is account credit
		if (select paymentmethod from Custom.Payment where id = @PaymentID) = 8
		Begin
			SET @RecordName = @RecordName + 1		
			INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
			SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), @LocationID, @DatafixUserID, @DatafixUserID, 0, @PaymentAmount, 'Account Credit, PMFIX for PMDEV-XXXXXX', j1.GLAccountName, j1.GLNumber, ch.ID, '368DB42A-D126-4E1F-B983-5643C2330A77', j1.GLAccountID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchId, 'None'
			FROM Custom.Payment p
				left join Custom.CreditHistory ch on p.ID = ch.PaymentId
				left join 
				(select top 1 * from Custom.GLJournal j where j.Reference_ObjectID = '368DB42A-D126-4E1F-B983-5643C2330A77' and j.LocationId = @LocationID Order by j.EffectiveDate desc) j1
				on p.LocationId = j1.LocationId
			WHERE p.ID = @PaymentID
		END

		--[Custom].[GLJournal] for tax
		SET @RecordName = @RecordName + 1		
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), @LocationID, @DatafixUserID, @DatafixUserID, @RefundedTax, 0, 'Refund on imported transaction, PMFIX for PMDEV-XXXXXX', j1.GLAccountName, j1.GLNumber, j1.Reference, j1.Reference_ObjectID, j1.GLAccountID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchId, 'None'
		FROM (select top 1 * from Custom.GLJournal j where j.Reference_ObjectID = 'FC7CEFC0-A08D-481F-B645-78E99E0E7516' and j.LocationId = @LocationID Order by j.EffectiveDate desc) j1
		OPTION (MAXDOP 1);

		--[Custom].[GLJournal] for revenue
		SET @RecordName = @RecordName + 1	
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), p.LocationId, @DatafixUserID, @DatafixUserID, @RefundedRevenue, 0, 'Refund on imported transaction, PMFIX for PMDEV-XXXXXX', it.RecordName, it.GLNumber, ci.id, '39D4288F-7468-4A3C-920E-96B4D0D51E97', it.ID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchId, 'None'
		FROM Custom.payment p
			left join Custom.Invoice i on i.Id = p.Invoice
			left join Custom.[Transaction] t on t.ID = i.TransactionID
			left join Custom.CartItem ci on ci.TransactionID = t.ID
			left join Custom.GLAccountAssignment glass on glass.Reference = CI.Item and (glass.LocationId = ci.LocationId or glass.LocationId is NULL)
			left join Custom.IncomeType it on glass.GLAccountId = it.ID
			left join Custom.GLAccountType glat on glat.ID = it.GLAccountType 
		WHERE p.ID = @PaymentID and glat.GLAccountType = 'Income' and (glass.EffectiveEndDate is null or glass.EffectiveEndDate > p.CreatedDate )

		OPTION (MAXDOP 1);


	SET @RowCount = @RowCount + 1


END