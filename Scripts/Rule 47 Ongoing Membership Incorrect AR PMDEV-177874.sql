/*
Author: Jing Su
Created Date: 2022-05-11
Modified Date: 2022-05-11

PMDEV-XXXXXX

What this script does:
	1. Insert AR and Tax/Revenue GL for imbalanced ongoing membership invoice

What you need to update:
	1.Update the DB number.
	2.Update the PMDEV- number.
	3.Update the Transaction RecordName.
	4.Execute. If successful, the following result will show :
	  'Executed Successfully!'


Alert:
	1.If the invoice is still imbanlanced after insertion, a warning will be raised.
	2.If the EffectivateDate is later than 3 calendar days, there will be warning and no GL will be inserted for that invoice.
	  Please comment out the 'if' statement for GL insertion or change the date difference limit if EffectivateDate is still
	  within 3 business days but not 3 calendar days.
*/


use G423595;
	
	DECLARE @transactions Table (recordname nvarchar(30))
	INSERT INTO @transactions Values ('214436')--change the recordname based on JIRA tickets


	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();

	drop table if exists #rule47
	 --delete from Custom.GLJournal where ReferenceDescription = 'PMFIX for PMDEV-XXXXXX'
	select ROW_NUMBER() OVER( ORDER BY t.modifieddate) RowID, j.GLAccountName, j.glnumber, j.glaccountid, j.reference, j.LocationId,
	j.reference_objectid, t.ModifiedDate, j.TransactionID , i.id as invoiceid, sum(j.NetBalance) as glnetbalance, i.RemainingBalance
	into #rule47
	from custom.GLJournal j
	left join Custom.[Transaction] t on t.ID = j.TransactionID
	left join Custom.Invoice i on j.InvoiceId = i.ID
	--left join Custom.Payment p on p.Invoice = i.id
	where t.RecordName in (select recordname from @transactions)
	and j.invoiceid is not null 
	--and i.Status = 0
	and j.reference_objectid = (select id from Framework.Object where tablename in ('Contact'))
	group by j.LocationId, j.GLAccountName, j.glnumber, j.glaccountid, j.reference, j.reference_objectid, t.ModifiedDate, j.TransactionID , i.id, i.remainingbalance
	having sum(j.NetBalance) <> i.remainingbalance
	
	select * from #rule47

	DECLARE @NumberRecords int
	DECLARE @RowCount int
	DECLARE @EffectiveDate datetime
	DECLARE @Contact uniqueidentifier
	DECLARE @Invoice uniqueidentifier
	DECLARE @LocationID uniqueidentifier

	SELECT @NumberRecords = max (RowID) from #rule47
	SET @RowCount = 1
	DECLARE @InsertedCount int = 0

	DECLARE @NumberOfTransactions int
	select @NumberOfTransactions = count(distinct(TransactionID)) from #rule47

WHILE @RowCount <= @NumberRecords
BEGIN
	Select @Contact = reference, @Invoice = invoiceid, @LocationID = LocationId
	from #rule47
	where RowID = @RowCount

	--find the imbalanced batch ID
	DECLARE @JournalBatchId int
	Select @JournalBatchId = (select max(JournalBatchId) from Custom.GLJournal
	where Reference = @Contact and InvoiceId = @Invoice)
	

	--create new recordname for gljournal
	DECLARE @RecordName int
    SELECT @RecordName = MAX(CAST(SUBSTRING(RecordName, 7, 6) AS int)) FROM Custom.GLJournal
    WHERE RecordName LIKE 'GLFIX-[0-9]%'
    IF @RecordName IS NULL SET @RecordName = 0


	DECLARE @Debit decimal(20, 2)
	DECLARE @Credit decimal(20, 2)

	Select @Debit = CASE
		WHEN glnetbalance-RemainingBalance >0
		THEN 0
		ELSE (glnetbalance-RemainingBalance)*-1
		END,
		@Credit = CASE
		WHEN glnetbalance-RemainingBalance >0
		THEN glnetbalance-RemainingBalance
		ELSE 0
		END
	from #rule47
	where RowID = @RowCount

	select @EffectiveDate = (select i.ModifiedDate from #rule47 r left join Custom.Invoice i on i.id = r.invoiceid where r.RowID = @RowCount)
	
	if (@EffectiveDate < (select ModifiedDate from #rule47 where RowID = @RowCount))
	begin
		set @EffectiveDate = (select ModifiedDate from #rule47 where RowID = @RowCount)
	end

	if (@EffectiveDate < (select top 1 EffectiveDate from Custom.GLJournal where InvoiceId=@Invoice))
	begin
		set @EffectiveDate = (select top 1 EffectiveDate from Custom.GLJournal where InvoiceId=@Invoice)
	end


	if(@UTCNow - @EffectiveDate>'1900-01-05 00:00:00.000')
	begin
		select 'Warning: The following EffectivateDate is later than 3 calandar days!!!'
		select * from #rule47
		where RowID = @RowCount
	end

	
	if(@UTCNow - @EffectiveDate<'1900-01-05 00:00:00.000')
	begin
		-- [Custom].[GLJournal] for AR	
		SET @InsertedCount = @InsertedCount + 1
		SET @RecordName = @RecordName + 1		
		INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
		SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), t.LocationId, @DatafixUserID, @DatafixUserID, @Debit, @Credit, 'PMFIX for PMDEV-XXXXXX', r.GLAccountName, r.GLNumber, r.Reference, r.Reference_ObjectID, r.GLAccountID, r.TransactionID, @EffectiveDate, r.invoiceid, @JournalBatchId, 'None'
		FROM #rule47 r
			left join Custom.[Transaction] t on t.id = r.transactionid
			left join custom.invoice i on i.ID = r.invoiceid
		WHERE RowID = @RowCount

		if(select sum(netbalance) from Custom.GLJournal where InvoiceId=@Invoice and reference_objectid='39D4288F-7468-4A3C-920E-96B4D0D51E97') = (select SubTotal from Custom.Invoice where ID=@Invoice)*-1
		begin	
			SET @InsertedCount = @InsertedCount + 1
			SET @RecordName = @RecordName + 1		
			INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
			SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), @LocationID, @DatafixUserID, @DatafixUserID, @Credit, @Debit, 'PMFIX for PMDEV-XXXXXX', j1.GLAccountName, j1.GLNumber, j1.Reference, j1.Reference_ObjectID, j1.GLAccountID, R.TransactionID, @EffectiveDate, @Invoice, @JournalBatchId, 'None'
			FROM #rule47 r
				left join (select top 1 * from Custom.GLJournal j where j.Reference_ObjectID = 'FC7CEFC0-A08D-481F-B645-78E99E0E7516' and j.InvoiceId = @Invoice Order by j.EffectiveDate desc) j1 on j1.LocationId = r.LocationId
			WHERE RowID = @RowCount
		end
		else
		begin
			SET @InsertedCount = @InsertedCount + 1
			SET @RecordName = @RecordName + 1		
			INSERT INTO [Custom].[GLJournal](ID, RecordName, LocationId, CreatedByUserID, ModifiedByUserID, Debit, Credit, ReferenceDescription, GLAccountName, GLNumber, Reference, Reference_ObjectID, GLAccountID, TransactionID, EffectiveDate, InvoiceId, JournalBatchId, PunchPassType)
			SELECT NEWID(), 'GLFIX-' + RIGHT('00000' + CAST(@RecordName as varchar(20)), 6), @LocationID, @DatafixUserID, @DatafixUserID, @Credit, @Debit, 'PMFIX for PMDEV-XXXXXX', j1.GLAccountName, j1.GLNumber, j1.Reference, j1.Reference_ObjectID, j1.GLAccountID, R.TransactionID, @EffectiveDate, @Invoice, @JournalBatchId, 'None'
			FROM #rule47 r
				left join (select top 1 * from Custom.GLJournal j where j.Reference_ObjectID = '39D4288F-7468-4A3C-920E-96B4D0D51E97' and j.InvoiceId = @Invoice Order by j.EffectiveDate desc) j1 on j1.LocationId = r.LocationId
			WHERE RowID = @RowCount
		end

	end

		

	SET @RowCount = @RowCount + 1


END	
	--check if there is still imbalanced invoice after the above fix
	drop table if exists #rule47qa
	select ROW_NUMBER() OVER( ORDER BY t.modifieddate) RowID, j.GLAccountName, j.glnumber, j.glaccountid, j.reference, j.reference_objectid, t.ModifiedDate, j.TransactionID , i.id as invoiceid, sum(j.NetBalance) as glnetbalance
	into #rule47qa
	from custom.GLJournal j
	left join Custom.[Transaction] t on t.ID = j.TransactionID
	left join Custom.Invoice i on j.InvoiceId = i.ID
	where t.RecordName in (select recordname from @transactions)
	and j.invoiceid is not null 
	--and i.Status = 0
	and j.reference_objectid = (select id from Framework.Object where tablename in ('Contact'))
	and exists (select * from Custom.Payment p where p.Invoice = i.ID and p.PaymentMethod = -1 and p.Amount = i.Amount)
	group by j.GLAccountName, j.glnumber, j.glaccountid, j.reference, j.reference_objectid, t.ModifiedDate, j.TransactionID , i.id
	having sum(j.NetBalance) <> 0
	
	SELECT @NumberRecords = max (RowID) from #rule47qa
	if(@NumberRecords>0)
	begin
		select 'Warning:' + CAST(@InsertedCount AS varchar(5)) + ' row(s) has/have been inserted. But the following invoice(s) is/are still not balanced!'
		select * from #rule47qa
	end
	else
	begin
		select 'Executed Successfully! ' +CAST(@NumberOfTransactions AS varchar(5)) +' transaction(s) has/have been fixed.' +CAST(@InsertedCount AS varchar(5)) + ' row(s) has/have been inserted. And every invoice is balanced after execution.'
	end