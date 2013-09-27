## query "execute count" metric via v$sysstat
set lin 200
set pagesize 100


drop table uow_sysstat purge;
create table uow_sysstat 
as 
select statistic#, value, sysdate logtime from v$sysstat;

pause wait 30 seconds before hit any key ...

drop table uow_sysstat_change purge;

create table uow_sysstat_change
as
select  
 d.name, 
 round((b.value - a.value)/(sysdate - a.logtime)/3600/24,1) call_per_sec,
 (b.value - a.value) delta,
 round((sysdate - a.logtime)* 3600 * 24) time_delta
from 
 v$statname d, v$sysstat b, uow_sysstat a 
where 
 a.statistic# = b.statistic# and 
 a.statistic# = d.statistic# and 
 d.name in ('execute count', 'user calls')
 and (b.value - a.value)  > 0 
order by  name;

select  name , sum(call_per_sec) from uow_sysstat_change group by  name; -- order by 3 desc;