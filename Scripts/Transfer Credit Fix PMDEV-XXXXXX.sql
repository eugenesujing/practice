/*
Author: Jing Su
Created Date: 2022-05-11
Modified Date: 2022-05-11


What this script does:
	1.Update credithistory GL's reference to the correct ID (for transfer credit)


What you should do:
	1.Change the DB number
	2.Change the transaction recordname
	
*/

use G422482;


	DECLARE @DatafixUserID uniqueidentifier = '7415F09F-3644-4B35-8E16-CF4796B57B9E';
	DECLARE @UTCNow datetime = GETUTCDATE();
	--please change the transaction recordname 
	DECLARE @TxnRecordName char(20) ='474513'

	DECLARE @RedeemCreditID uniqueidentifier ;
	DECLARE @AddCreditID uniqueidentifier;

	DECLARE @RedeemGLRecordName char(20);
	DECLARE @AddGLRecordName char(20);

	select @RedeemCreditID = ch.id from custom.credithistory ch
	left join custom.[transaction] t on t.id = ch.[transaction]
	where t.recordname = @TxnRecordName and ch.amount<0

	select @AddCreditID = ch.id from custom.credithistory ch
	left join custom.[transaction] t on t.id = ch.[transaction]
	where t.recordname = @TxnRecordName and ch.amount>0

	select @RedeemGLRecordName=j.recordname from custom.gljournal j
	left join custom.[transaction] t on t.id = j.transactionid
	where t.recordname = @TxnRecordName and j.reference_objectid = '368DB42A-D126-4E1F-B983-5643C2330A77'
	and j.debit>0

	select @AddGLRecordName=j.recordname from custom.gljournal j
	left join custom.[transaction] t on t.id = j.transactionid
	where t.recordname = @TxnRecordName and j.reference_objectid = '368DB42A-D126-4E1F-B983-5643C2330A77'
	and j.credit>0

	update custom.gljournal
	set reference = @RedeemCreditID, modifieddate = @UTCNow, modifiedbyuserid = @DatafixUserID
	where recordname = @RedeemGLRecordName

	update custom.gljournal
	set reference = @AddCreditID, modifieddate = @UTCNow, modifiedbyuserid = @DatafixUserID
	where recordname = @AddGLRecordName