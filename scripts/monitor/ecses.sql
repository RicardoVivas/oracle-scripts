## query "execute count" metric via v$sesstat

set lin 200
set pagesize 100


drop table uow_sesstat purge;
create table uow_sesstat 
as 
select sid, statistic#, value, sysdate logtime from v$sesstat;

pause wait 30 seconds before hit any key ...

drop table uow_sesstat_change purge;

create table uow_sesstat_change
as
select  
 (case   when c.username is null then c.program  else c.username end) username,
 c.sid,
 d.name, 
 round((b.value - a.value)/(sysdate - a.logtime)/3600/24,1) call_per_sec,
 (b.value - a.value) delta,
 round((sysdate - a.logtime)* 3600 * 24) time_delta
from 
 v$statname d, v$session c, v$sesstat b, uow_sesstat a 
where 
 a.sid = b.sid and 
 a.statistic# = b.statistic# and 
 b.sid = c.sid and 
 a.statistic# = d.statistic# and 
 d.name in ('execute count', 'user calls')
 and (b.value - a.value)  > 0 
order by c.username,c.sid,  name;

select username, name , sum(call_per_sec) from uow_sesstat_change group by rollup(username, name); -- order by 3 desc;
 