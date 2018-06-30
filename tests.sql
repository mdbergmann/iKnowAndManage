select * from element where id=2182;
select count(*) from element where identifier like '108';
select * from elementvalue where elementid=2182;
select * from elementvalue where valuedata='734';
select * from documentmeta;
select count(*) from elementvalue;
select count(*) from element where treeinfo like (select treeinfo from element where id = 1)||'.%' AND identifier like '3__';
select count(*) from element where treeinfo like (select treeinfo from element where id = 1)||'.%' AND identifier like '1__';
select count(*) from element e,elementvalue ev where e.treeinfo like (select treeinfo from element where id=1)||'.%' AND e.identifier like 'itemvalue';
select count(*) from element where parentid = 3;
select count(*) from element where treeinfo like (select treeinfo from element where id=1)||'.%.' AND identifier like '3__';
select ev.id,ev.elementid,ev.valuetype,ev.identifier from elementvalue ev left outer join element e on e.id = ev.elementid where e.parentid=3 AND e.identifier like '3__' AND ev.identifier like 'itemvaluename';
select id,gpreg,valuedata from elementvalue where gpreg & 2;
insert into element select * from element where treeinfo like '3.%'

delete from elementvalue where elementid in (select id from element where treeinfo like '.1%');
delete from element where treeinfo like '.1%';
select id from element where treeinfo like '.1%';
select * from elementvalue where id=4;
delete from elementvalue where elementid=546;
delete from element where id=546;
select id,elementid,identifier,valuetype,valuedata from elementvalue;
select id,elementid,identifier from elementvalue;
create index elemvalindex on elementvalue (id,elementid,identifier,valuetype);
drop index elemvalindex;

select * from elementvalue where valuedata like '%software%';
select * from elementvalue where valuedata like 'hallo';
update elementvalue set valuedata='%A, %B %e, %Y %H:%M' where identifier like 'itemvaluedateformatterstring';

select cast((valuedata+100) as integer) from elementvalue where identifier='itemvaluetype';

update elementvalue set valuedata = cast((valuedata+100) as integer) where identifier='itemtype';
update element set identifier = cast(identifier as integer);
update element set identifier = -1 where id = 1;

select valuedatasize,gpreg,identifier,elementid,valuetype,id,valuedata from elementvalue where valuedatasize > 8192;

create table valueindex ( elemvalid INTEGER, elemvalidentifier TEXT, elemvalcontent TEXT, PRIMARY KEY(elemvalid) );
insert into valueindex select id, identifier, valuedata from elementvalue;
select * from valueindex;
select ev.elementid, ei.elemvalid, ei.elemvalcontent from valueindex ei, elementvalue ev where (ei.elemvalid = ev.id) AND (ei.elemvalcontent like '%h%');
select count(*) from valueindex ei, elementvalue ev where (ei.elemvalid = ev.id) AND (ei. elemvalcontent like '%h%');
select e.treeinfo, ev.elementid, ei.elemvalid, ei.elemvalcontent from valueindex ei 
												left outer join elementvalue ev on ev.id = ei.elemvalid 
												left outer join element e on ev.elementid = e.id 
												where ei.elemvalcontent like '%hesitate%' AND
												e.treeinfo like '.1.%';
select count(*) from valueindex ei left outer join elementvalue ev on ev.id = ei.elemvalid where ei.elemvalcontent like '%h%';
drop table valueindex;

select * from valueindex where elemvalcontent like 'Bibel';
select * from sqlite_master;
vacuum;
select * from elementvalue where gpreg & 2;
select count(*) from elementvalue where gpreg & 2 and valuedata = '37';
select * from documentmeta;
delete from documentmeta where id=50;
select distinct id from documentmeta where id in (select valuedata from elementvalue where gpreg & 2);
select distinct id from documentmeta where id not in (select valuedata from elementvalue where gpreg & 2);
update documentmeta set instancecount=(select count(*) from elementvalue ev, documentmeta dm where ev.gpreg & 2 and dm.id = ev.valuedata);

select * from element where identifier='120'; 
select * from elementvalue where identifier='itemvaluetype' and valuedata='120';

update element set identifier=120 where identifier=107;
update element set identifier=121 where identifier=108;
update element set identifier=122 where identifier=109;
update element set identifier=123 where identifier=101;
update elementvalue set valuedata='120' where valuedata='107' and identifier='itemvaluetype';
update elementvalue set valuedata='121' where valuedata='108' and identifier='itemvaluetype';
update elementvalue set valuedata='122' where valuedata='109' and identifier='itemvaluetype';
update elementvalue set valuedata='123' where valuedata='101' and identifier='itemvaluetype';