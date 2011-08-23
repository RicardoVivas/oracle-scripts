clear
col EVENT format a20
col USERNAME format a20

select to_char(a.sample_time,'hh24:mi:ss') sample_time, b.username,  
a.session_state,  a.blocking_session, a.event,  a.session_type, a.session_id, a.sql_id, a.sql_plan_hash_value, a.program, a.client_id
from 
v$active_session_history a, dba_users b  
where a.user_id = b.user_id and b.username not in ( 'DBSNMP') and a.sample_time > sysdate - 1/24/12 
order by a.sample_time ;