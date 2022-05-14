/*Generic fix for Pods Swimming rule 35
inset into one row for credithistory payment and one for account receivable*/


--PMDEV-172516
use G425513;

	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();
	
	drop table if exists #rule35

	--retrieve data about the credit history record that violates rule 35
	select ROW_NUMBER() OVER( ORDER BY p.createddate) RowID,
	p.invoice as InvoiceID, ch.ID as CreditHistoryID, ch.[Transaction], p.LocationId, ch.Contact, ch.createddate,
	CASE WHEN ch.Amount < 0 THEN ch.Amount*-1 ELSE ch.Amount END as Amount
	into #rule35
	from Custom.CreditHistory ch
	left join Custom.Payment p on p.id = ch.PaymentId
	--change the credit history recordname
	where ch.RecordName in ('CR-01437','CR-01439','CR-01441','CR-01443','CR-01445','CR-01448','CR-01454')

	--SELECT * FROM #RULE35
	DECLARE @CreditHistoryID Uniqueidentifier
	DECLARE @InvoiceID Uniqueidentifier
	DECLARE @ContactID Uniqueidentifier
	DECLARE @TransactionID Uniqueidentifier
	DECLARE @LocationID Uniqueidentifier
	DECLARE @EffectiveDate datetime
	DECLARE @Amount decimal(20,2)
	DECLARE @NumberRecords int
	DECLARE @RowCount int

	SELECT @NumberRecords = max (RowID) from #rule35 
	SET @RowCount = 1


WHILE @RowCount <= @NumberRecords
BEGIN
	--create new batch ID
	DECLARE @JournalBatchId int
	SELECT @JournalBatchId =  max(JournalBatchId) from Custom.GLJournal
	SET @JournalBatchId = ISNULL(@JournalBatchId, 0) + 1


	DECLARE @Debit decimal(20,2)
	DECLARE @Credit decimal(20,2)


	--create new recordname for gljournal
	DECLARE @RecordName int
    SELECT @RecordName = MAX(CAST(SUBSTRING(RecordName, 7, 6) AS int)) FROM Custom.GLJournal
    WHERE RecordName LIKE 'GLFIX-[0-9]%'
    IF @RecordName IS NULL SET @RecordName = 0

	SELECT @CreditHistoryID = CreditHistoryID, @InvoiceID= InvoiceID, @ContactID = Contact,
	@TransactionID = [Transaction], @LocationID = LocationID, @EffectiveDate = CreatedDate, @Amount = Amount
	FROM #rule35
	WHERE RowID = @RowCount

	SELECT @Debit = CASE WHEN ch.Amount <0 THEN ch.Amount*-1 ELSE 0 END,
	@Credit = CASE WHEN ch.Amount>0 THEN ch.Amount ELSE 0 END
	from Custom.CreditHistory ch
	where ch.id = @CreditHistoryID

	--if the GL for account credit payment is missing
	if (select reference from custom.gljournal where Reference = @CreditHistoryID) IS NULL
	Begin

	-- [Custom].[GLJournal] for Payment	
		SET @RecordName = @RecordName + 1		
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), @LocationID, @DatafixUserID, @DatafixUserID, @Debit, @Credit, 'Account Credit, PMFIX for PMDEV-172516', j1.GLAccountName, j1.GLNumber, @CreditHistoryID, '368DB42A-D126-4E1F-B983-5643C2330A77', j1.GLAccountID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchId, 'None'
		FROM Custom.CreditHistory ch
			left join 
			(select top 1 * from Custom.GLJournal j where j.Reference_ObjectID = '368DB42A-D126-4E1F-B983-5643C2330A77' and j.LocationId = @LocationID Order by j.EffectiveDate desc) j1
			on ch.LocationId = j1.LocationId
		WHERE ch.ID = @CreditHistoryID


		--[Custom].[GLJournal] for contact	
		SET @RecordName = @RecordName + 1
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), i.LocationId, @DatafixUserID, @DatafixUserID, @Credit, @Debit, c.FullNameSimple + ', PMFIX for PMDEV-172516' ,it.recordname, it.GLNumber, c.ID, '88F18A02-BBDD-45B6-9B44-DE9AE0FF6500', it.ID, i.TransactionID, @EffectiveDate, i.ID, @JournalBatchId, 'None'
		FROM Custom.Invoice i 
				join Custom.Contact c on i.ContactId = c.ID 
				join Custom.IncomeType it on it.GLAccountCategory = '012F4726-C621-483A-9991-03EAE84F5EA4' and it.GLAccountType = 'F7550BA8-9DE8-4ED3-986B-9354394372AE' AND IsSystem = 1
		WHERE i.ID = @InvoiceID
		
		--GLJournalDetail
		/*INSERT INTO Custom.GLJournalDetail (ID, LocationId, CreatedByUserID, ModifiedByUserID, GLJournalID, CartItemID, Debit, Credit)
		SELECT NEWID(), gl.LocationId, @DatafixUserID, @DatafixUserID, gl.ID, NULL, gl.Debit, gl.Credit
		FROM [Custom].[GLJournal] gl 
				join Custom.Invoice i on gl.InvoiceId = i.ID
		WHERE JournalBatchId = @JournalBatchId*/

	End

	ELSE
	--if there's existing related GL for the credit history but the amount is less than the correct amount
	BEGIN
		IF (select sum(j.NetBalance) from custom.gljournal j where j.Reference = @CreditHistoryID ) < @Amount
		BEGIN
			DECLARE @Difference decimal(20,2) 
			SET @Difference = @Amount - (select sum(j.NetBalance) from custom.gljournal j where j.Reference = @CreditHistoryID )
			
			-- [Custom].[GLJournal] for Payment	
			SET @RecordName = @RecordName + 1		
			INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
			SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), @LocationID, @DatafixUserID, @DatafixUserID, @Difference, 0, 'Account Credit, PMFIX for PMDEV-172516', j1.GLAccountName, j1.GLNumber, @CreditHistoryID, '368DB42A-D126-4E1F-B983-5643C2330A77', j1.GLAccountID, @transactionID, @EffectiveDate, @InvoiceID, @JournalBatchId, 'None'
			FROM Custom.CreditHistory ch
				left join 
				(select top 1 * from Custom.GLJournal j where j.Reference_ObjectID = '368DB42A-D126-4E1F-B983-5643C2330A77' and j.LocationId = @LocationID Order by j.EffectiveDate desc) j1
				on ch.LocationId = j1.LocationId
			WHERE ch.ID = @CreditHistoryID


			--[Custom].[GLJournal] for contact	
			SET @RecordName = @RecordName + 1
			INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
			SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), i.LocationId, @DatafixUserID, @DatafixUserID, 0, @Difference, c.FullNameSimple + ', PMFIX for PMDEV-172516' ,it.recordname, it.GLNumber, c.ID, '88F18A02-BBDD-45B6-9B44-DE9AE0FF6500', it.ID, i.TransactionID, @EffectiveDate, i.ID, @JournalBatchId, 'None'
			FROM Custom.Invoice i 
				join Custom.Contact c on i.ContactId = c.ID 
				join Custom.IncomeType it on it.GLAccountCategory = '012F4726-C621-483A-9991-03EAE84F5EA4' and it.GLAccountType = 'F7550BA8-9DE8-4ED3-986B-9354394372AE' AND IsSystem = 1
			WHERE i.ID = @InvoiceID
		
			--GLJournalDetail
			/*INSERT INTO Custom.GLJournalDetail (ID, LocationId, CreatedByUserID, ModifiedByUserID, GLJournalID, CartItemID, Debit, Credit)
			SELECT NEWID(), gl.LocationId, @DatafixUserID, @DatafixUserID, gl.ID, NULL, gl.Debit, gl.Credit
			FROM [Custom].[GLJournal] gl 
				join Custom.Invoice i on gl.InvoiceId = i.ID
			WHERE JournalBatchId = @JournalBatchId*/

		END
	END
	SET @RowCount = @RowCount + 1


END