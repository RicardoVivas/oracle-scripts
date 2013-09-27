clear
col EVENT format a20
col USERNAME format a20

select to_char(a.sample_time,'hh24:mi:ss') sample_time, substr(b.username,1,9) username,  
a.session_state,  a.blocking_session, substr(a.event,1,30), substr(a.program,1,30),  a.session_id,
 a.sql_id,  a.sql_plan_hash_value,   a.client_id
from 
v$active_session_history a, dba_users b  
where a.user_id = b.user_id and b.username not in ( 'DBSNMP') and a.sample_time > sysdate - 0.125/24 
--and sql_plan_hash_value = '186864253'
order by a.sample_time ;