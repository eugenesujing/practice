/*Generic fix for rule 33
inset into one row for payment and one for account receivable*/


--PMDEV-172589
use G423910;

	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();
	
	drop table if exists #rule33

	select ROW_NUMBER() OVER( ORDER BY p.createddate) RowID,
	i.id as InvoiceID, p.ID as PaymentID, i.TransactionID, p.LocationId, i.ContactId, 
	p.CreatedDate /*If payment method is 1,2,4, effectivedate should be settlement date, otherwise created date*/
	into #rule33
	from Custom.Invoice i
	left join Custom.Payment p on p.invoice = i.id
	--change the payment recordname
	where p.RecordName in ('PYMT-77560')

	DECLARE @PaymentID Uniqueidentifier
	DECLARE @InvoiceID Uniqueidentifier
	DECLARE @ContactID Uniqueidentifier
	DECLARE @TransactionID Uniqueidentifier
	DECLARE @LocationID Uniqueidentifier
	DECLARE @EffectiveDate datetime
	DECLARE @NumberRecords int
	DECLARE @RowCount int

	SELECT @NumberRecords = max (RowID) from #rule33 
	SET @RowCount = 1


WHILE @RowCount <= @NumberRecords
BEGIN
	DECLARE @JournalBatchId int
	SELECT @JournalBatchId =  max(JournalBatchId) from Custom.GLJournal
	SET @JournalBatchId = ISNULL(@JournalBatchId, 0) + 1

	DECLARE @RecordName int
    SELECT @RecordName = MAX(CAST(SUBSTRING(RecordName, 7, 6) AS int)) FROM Custom.GLJournal
    WHERE RecordName LIKE 'GLFIX-[0-9]%'
    IF @RecordName IS NULL SET @RecordName = 0

	SELECT @PaymentID = PaymentID, @InvoiceID= InvoiceID, @ContactID = ContactID,
	@TransactionID = TransactionID, @LocationID = LocationID, @EffectiveDate = CreatedDate
	FROM #rule33
	WHERE RowID = @RowCount

	/*If payment method is 1,2,4, effectivedate should be settlement date, otherwise created date*/

	if (select paymentmethod from Custom.Payment where id = @PaymentID) in (1, 2 ,4 )
	Begin
		Select @EffectiveDate = p.settlementdate
		from Custom.Payment p
		Where p.id = @PaymentID
	End


	if (select reference from custom.gljournal where Reference = @PaymentID) IS NULL
	Begin
	-- [Custom].[GLJournal] for Payment	
		SET @RecordName = @RecordName + 1		
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), p.LocationId, @DatafixUserID, @DatafixUserID, p.Amount, 0, 'PMFIX for PMDEV-172589', it.RecordName, it.GLNumber, p.id, '67F02CDA-018F-4F1D-ABC0-960ED27F9006', it.ID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchId, 'None'
		FROM Custom.payment p
				join Custom.GLAccountAssignment glass on glass.Reference = (select referenceid from custom.paymentmethod where id =  p.paymentmethod) and glass.EffectiveEndDate IS NULL
				join Custom.IncomeType it on glass.GLAccountId = it.ID
		WHERE p.ID = @PaymentID
		OPTION (MAXDOP 1);

		--[Custom].[GLJournal] for contact	
		SET @RecordName = @RecordName + 1
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), i.LocationId, @DatafixUserID, @DatafixUserID, 0, (select Amount from custom.Payment p where id = @PaymentID), c.FullNameSimple + ', PMFIX for PMDEV-172589' ,it.recordname, it.GLNumber, c.ID, '88F18A02-BBDD-45B6-9B44-DE9AE0FF6500', it.ID, i.TransactionID, @EffectiveDate, i.ID, @JournalBatchId, 'None'
		FROM Custom.Invoice i 
				join Custom.Contact c on i.ContactId = c.ID 
				join Custom.IncomeType it on it.GLAccountCategory = '012F4726-C621-483A-9991-03EAE84F5EA4' and it.GLAccountType = 'F7550BA8-9DE8-4ED3-986B-9354394372AE' AND IsSystem = 1
		WHERE i.ID = @InvoiceID
		OPTION (MAXDOP 1);

		--GLJournalDetail
		/*INSERT INTO Custom.GLJournalDetail (ID, LocationId, CreatedByUserID, ModifiedByUserID, GLJournalID, CartItemID, Debit, Credit)
		SELECT NEWID(), gl.LocationId, @DatafixUserID, @DatafixUserID, gl.ID, NULL, gl.Debit, gl.Credit
		FROM [Custom].[GLJournal] gl 
				join Custom.Invoice i on gl.InvoiceId = i.ID
		WHERE JournalBatchId = @JournalBatchId
		OPTION (MAXDOP 1);*/

	END
	SET @RowCount = @RowCount + 1


END