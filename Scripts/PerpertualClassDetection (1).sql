use G425351

DECLARE @transactions Table (recordname nvarchar(30))
INSERT INTO @transactions Values ('1158'),('1215'),('1226'),('1230'),('1231'),('1246'),('1249'),('1252'),('1259'),('1274'),('1278'),('1284'),('1286'),('1293'),('1296'),('1305'),('1311'),('1314'),('220'),('223'),('225'),('231'),('235'),('240'),('2402'),('2419'),('2464'),('2467'),('2471'),('249'),('2498'),('256'),('260'),('267'),('269'),('272'),('2739'),('2743'),('2744'),('2749'),('275'),('2751'),('2757'),('2758'),('2762'),('2766'),('2769'),('2772'),('2777'),('2778'),('278'),('2780'),('282'),('284'),('2864'),('291'),('295'),('297'),('299'),('302'),('306'),('308'),('3092'),('3093'),('3097'),('310'),('3100'),('3102'),('313'),('316'),('320'),('326'),('328'),('329'),('333'),('335'),('336'),('337'),('341'),('343'),('344'),('346'),('351'),('357'),('360'),('361'),('368'),('370'),('376'),('378'),('381'),('387'),('3913'),('3919'),('3920'),('3924'),('3925'),('3928'),('3932'),('3934'),('3948'),('3950'),('3953'),('3955'),('3959'),('409'),('413'),('4176'),('4177'),('421'),('4251'),('4274'),('4276'),('4291'),('4303'),('4304'),('4305'),('4308'),('4309'),('431'),('4312'),('432'),('4360'),('4378'),('4406'),('4413'),('4416'),('4418'),('4421'),('4424'),('4426'),('4430'),('4486'),('4492'),('4508'),('488'),('525'),('560'),('568'),('570'),('572'),('580'),('582'),('583'),('584'),('585'),('586'),('594'),('595'),('597'),('601'),('616'),('6529'),('6531'),('6534'),('6538'),('6540'),('6543'),('6545'),('6546'),('6549'),('6550'),('6552'),('6568'),('6569'),('6572'),('6579'),('6583'),('6584'),('6586'),('6599'),('6600')


/*select * from Custom.Payment where recordname in ('PYMT-17877','PYMT-18031','PYMT-17866','PYMT-17878','PYMT-18020','PYMT-17868','PYMT-17781','PYMT-18041','PYMT-18082','PYMT-17896','PYMT-17828','PYMT-17989','PYMT-18050','PYMT-18058','PYMT-18072','PYMT-17806','PYMT-17935','PYMT-17822','PYMT-17877','PYMT-17808','PYMT-17879','PYMT-18006','PYMT-18081','PYMT-17798','PYMT-17938','PYMT-17970','PYMT-17903','PYMT-17990','PYMT-17861','PYMT-18054','PYMT-17805','PYMT-17867','PYMT-17819','PYMT-17987','PYMT-17952','PYMT-17835','PYMT-17905','PYMT-17969','PYMT-17966','PYMT-18070','PYMT-17833','PYMT-17967','PYMT-17816','PYMT-17910','PYMT-17998','PYMT-17996','PYMT-17786','PYMT-17788','PYMT-17839','PYMT-17991','PYMT-17797','PYMT-17869','PYMT-17876','PYMT-18047','PYMT-17792','PYMT-17982','PYMT-17837','PYMT-17993','PYMT-18003','PYMT-17900','PYMT-18021','PYMT-18067','PYMT-17894','PYMT-17923','PYMT-17937','PYMT-17943','PYMT-17779','PYMT-17874','PYMT-17994','PYMT-17917','PYMT-18004','PYMT-17774','PYMT-17799','PYMT-17968','PYMT-17859','PYMT-17983','PYMT-17947','PYMT-18046','PYMT-17963','PYMT-17855','PYMT-17984','PYMT-17913','PYMT-18075','PYMT-17898','PYMT-17821','PYMT-17897','PYMT-18074','PYMT-17771','PYMT-17979','PYMT-17889','PYMT-17960','PYMT-17992','PYMT-17915','PYMT-18016','PYMT-17936','PYMT-18030','PYMT-17851','PYMT-17999','PYMT-17934','PYMT-17825','PYMT-18028','PYMT-17940','PYMT-18044','PYMT-17809','PYMT-17885','PYMT-17789','PYMT-18027','PYMT-17794','PYMT-18071','PYMT-17841','PYMT-17912','PYMT-17961','PYMT-17920','PYMT-18043','PYMT-18040','PYMT-18010','PYMT-17881','PYMT-17957','PYMT-18066','PYMT-18057','PYMT-18062','PYMT-18059','PYMT-17849','PYMT-17914','PYMT-18064','PYMT-17958','PYMT-18001','PYMT-17919','PYMT-17802','PYMT-18042','PYMT-18038','PYMT-17911','PYMT-17856','PYMT-17886','PYMT-17823','PYMT-17890','PYMT-18031','PYMT-17845','PYMT-17981','PYMT-18053','PYMT-17955','PYMT-17847','PYMT-18077','PYMT-17907','PYMT-17812','PYMT-17801','PYMT-17807','PYMT-17870','PYMT-18060','PYMT-17924','PYMT-17975','PYMT-17838','PYMT-17776','PYMT-17956','PYMT-17977','PYMT-17902','PYMT-17901','PYMT-17815','PYMT-17810','PYMT-18051','PYMT-17959','PYMT-17951','PYMT-17784','PYMT-18013','PYMT-17782','PYMT-17829','PYMT-17777','PYMT-17904','PYMT-17848','PYMT-18002','PYMT-17942','PYMT-17930','PYMT-17973','PYMT-17978','PYMT-17948','PYMT-17974','PYMT-17858','PYMT-17971','PYMT-17882','PYMT-18069','PYMT-17884','PYMT-18009','PYMT-18055','PYMT-17866','PYMT-18084','PYMT-17916','PYMT-17922','PYMT-18083','PYMT-17931','PYMT-17773','PYMT-18025','PYMT-17824','PYMT-18073','PYMT-17796','PYMT-17976','PYMT-17853','PYMT-17827','PYMT-17887','PYMT-17878','PYMT-17986','PYMT-18017','PYMT-17933','PYMT-18037','PYMT-18036','PYMT-17830','PYMT-17988','PYMT-18034','PYMT-17818','PYMT-17944','PYMT-18018','PYMT-18080','PYMT-17965','PYMT-17860','PYMT-18063','PYMT-17926','PYMT-17891','PYMT-17997','PYMT-17852','PYMT-18048'
) and details <> 'Failed by PMDEV-165855'*/

-- Retrieve transaction recordname by payment recordname
/*
select t.RecordName 
from custom.[Transaction] t
left join custom.invoice i on i.TransactionID = t.id
left join custom.payment p on p.Invoice = i.id
where p.RecordName in('PYMT-17982','PYMT-17947','PYMT-17870','PYMT-17776'
) */


-- Invoices
/*
select t.RecordName, i.*
from custom.Invoice i
left join custom.[transaction] t on t.id = i.TransactionID
where t.recordname not in (select recordname from @transactions)
	--and i.status = 5
	--and i.ModifiedDate > '2021-08-30 06:00'
order by i.CreatedDate desc, t.RecordName
--*/

-- New Journals
/*
select t.RecordName, j.*
from custom.gljournal j
left join custom.[transaction] t on t.id = j.TransactionID
where t.recordname not in (select recordname from @transactions)
	and j.createddate > '2021-09-01 0:00'
	--and i.status = 5
	--and i.ModifiedDate > '2021-08-30 06:00'
order by j.CreatedDate desc, t.RecordName
--*/



--Check if transaction contains perpetual class, if empty, only perpetual classes
select 'Perpetual Class Check'
select t.RecordName
from custom.[Transaction] t
left join custom.CartItem ci on ci.TransactionID = t.ID
left join custom.OngoingInvoiceTemplate oit on oit.CartItemId = ci.id
where t.recordname in (select recordname from @transactions)
	and oit.ID is null


--
select 'Forfeit Revenue Net Balance Check'
select t.RecordName, i.RecordName, i.SubTotal, j.GLAccountName, sum(j.netbalance) as glnetbalance
from custom.[Transaction] t
left join custom.Invoice i on i.TransactionID = t.id
left join custom.GLJournal j on j.TransactionID = t.id and j.InvoiceId = i.id
where t.recordname in (select recordname from @transactions)
	and j.Reference_ObjectID = '39D4288F-7468-4A3C-920E-96B4D0D51E97' 
	and i.Status in ('5')
	--and i.Status not in ('5', '4')
group by i.RecordName, t.RecordName, i.SubTotal, j.GLAccountName
having sum(j.netbalance) != 0
order by t.RecordName


--
select 'AR - Invoice RB Imbalance	'
select t.RecordName, i.RecordName, i.CreatedDate as InvoiceCreatedDate, i.InvoiceDueDate, i.ModifiedDate, sum(j.netbalance) as glnetbalance
from custom.[transaction] t
left join custom.Invoice i on i.TransactionID = t.id
left join custom.GLJournal j on j.TransactionID = t.id and j.InvoiceId = i.id
where j.Reference_ObjectID = '88F18A02-BBDD-45B6-9B44-DE9AE0FF6500' 
	--and i.id in (select fid.invoiceID from dbo.ForfeitInvoiceID fid)
	and t.recordname in (select recordname from @transactions)
group by i.RecordName, i.CreatedDate, i.InvoiceDueDate,  t.RecordName, i.ModifiedDate, i.RemainingBalance
having sum(j.netbalance) != i.RemainingBalance
order by t.RecordName


--
select 'AR null invoice on Canadabay'
select t.RecordName, sum(j.netbalance) as glnetbalance
from custom.[transaction] t
left join custom.GLJournal j on j.TransactionID = t.id
where j.Reference_ObjectID = '88F18A02-BBDD-45B6-9B44-DE9AE0FF6500' 
	and J.InvoiceId is null
	and t.recordname in (select recordname from @transactions)
group by t.RecordName
having sum(j.netbalance) != 0
order by t.RecordName


--
select 'Revenue Invoice Subtotal Check'
select t.RecordName, i.RecordName, i.CreatedDate as InvoiceCreatedDate, i.InvoiceDueDate, i.ModifiedDate, i.SubTotal, sum(j.Credit) as glCreditBalance, sum(j.NetBalance) as glNetBalance
from custom.[transaction] t
left join custom.Invoice i on i.TransactionID = t.id
left join custom.GLJournal j on j.TransactionID = t.id and j.InvoiceId = i.id
where j.Reference_ObjectID = '39D4288F-7468-4A3C-920E-96B4D0D51E97' 
	and t.recordname in (select recordname from @transactions)
	and i.Status not in ('4', '5')
group by i.RecordName, i.CreatedDate, i.InvoiceDueDate,  t.RecordName, i.ModifiedDate, i.SubTotal
having sum(j.Credit) != i.SubTotal and sum(j.netbalance) !=  -i.subTotal
order by t.RecordName


--
select 'Sale Batch Invoice Check'
select t.RecordName, i.RecordName, i.CreatedDate as InvoiceCreatedDate, i.InvoiceDueDate, i.ModifiedDate
from custom.[transaction] t
left join custom.Invoice i on i.TransactionID = t.id
where t.recordname in (select recordname from @transactions)
	--and i.Status not in ('4', '5')
	and i.IsPayNow = 0
	and not exists (
		select top 1 j.credit
		from custom.gljournal j
		where j.InvoiceId = i.ID
			and j.Reference_ObjectID = '39D4288F-7468-4A3C-920E-96B4D0D51E97' 
			and j.Credit != 0
		)
group by i.RecordName, i.CreatedDate, i.InvoiceDueDate,  t.RecordName, i.ModifiedDate, i.SubTotal
order by t.RecordName


--
select 'Invoice GL Entries Check'
select t.RecordName, i.RecordName, j.InvoiceId
from custom.invoice i
join custom.[transaction] t  on i.TransactionID = t.id
left outer join custom.GLJournal j on j.InvoiceId = i.ID
where t.recordname in (select recordname from @transactions)
	and j.InvoiceId is null
	--and i.Status not in ('4', '5')
order by t.RecordName


select 'Check Invoice ID Null GLs'
select *
from custom.GLJournal j
left join custom.[Transaction] t on t.id = j.transactionID
where t.recordname in (select recordname from @transactions)
	and j.InvoiceId is null
