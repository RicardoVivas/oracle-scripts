
----------- Individual datfile IO ------------------
clear
drop table uow_filestat purge;
drop table uow_sysstat purge;

create table uow_filestat 
as 
select 
a.phyblkwrt, a.phywrts, a.phyrds, phyblkrd,
b.file#, b.name, sysdate logtime 
from v$filestat a , v$datafile b 
where a.file# = b.file#;

create table uow_sysstat as select a.name, a.value, sysdate logtime  
from v$sysstat a 
where name in( 'physical write total bytes', 'physical read total bytes');

pause wait several seconds before hit any key ...

select 
substr(b.name,1,60) short_name, 
(a.phyblkwrt - b.phyblkwrt) phywrts, 
( a.phyblkrd - b.phyblkrd ) phyblkrd, 
round((a.phyblkwrt - b.phyblkwrt)/((sysdate - b.logtime) * 24 * 3600)) write_blocks_per_sec, 
round((a.phywrts - b.phywrts)    /((sysdate - b.logtime) * 24 * 3600)) write_per_sec,
round((a.phyblkrd - b.phyblkrd ) /((sysdate - b.logtime) * 24 * 3600)) read_blocks_per_sec, 
round((a.phyrds - b.phyrds)      /((sysdate - b.logtime) * 24 * 3600)) read_per_sec,
round( (sysdate - b.logtime) * 24 * 3600 )  logtime 
from v$filestat a , uow_filestat  b 
where a.file# = b.file# 
order by (a.phyblkwrt - b.phyblkwrt + a.phyblkrd - b.phyblkrd) desc;


select round((a.value - b.value)/1024/1024) write_MB, 
round((a.value - b.value)/((sysdate - b.logtime) * 24 * 3600)/1024/1024, 2) write_MB_per_sec,
round(((sysdate - b.logtime) * 24 * 3600))  logtime 
from  v$sysstat a, uow_sysstat b where a.name = b.name


 