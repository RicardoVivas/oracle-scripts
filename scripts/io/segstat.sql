clear
drop table segstat_base;
drop table segstat_delta;

create table segstat_base as 
select a.*, sysdate as log_time from v$segstat a;


pause wait several seconds before hit any key ...

create table segstat_delta
as
select b.ts#, b.obj#, b.DATAOBJ#, b.statistic_name, b.value - a.value value_delta, sysdate as log_time 
from v$segstat b, segstat_base a
where a.STATISTIC_NAME = b.STATISTIC_NAME and a.obj# = b.obj# and a.dataobj# = b.dataobj#;

select a.owner, substr(a.object_name,1, 30) short_name, b.statistic_name, b.value_delta from segstat_delta b, dba_objects a 
where b.obj# = a.object_id and b.value_delta > 0 
order by b.value_delta desc;

