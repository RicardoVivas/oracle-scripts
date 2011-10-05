clear
col EVENT format a20
col USERNAME format a20

select to_char(a.sample_time,'hh24:mi:ss') sample_time, substr(b.username,1,9) username,  
a.session_state,  a.blocking_session, substr(a.SQL_OPNAME,1,8) sql_opame, substr(a.event,1,40), a.program,  a.session_id,
 a.sql_id,  a.sql_plan_hash_value,  a.session_type, a.client_id
from 
v$active_session_history a, dba_users b  
where a.user_id = b.user_id and b.username not in ( 'DBSNMP') and a.sample_time > sysdate - 1/24/12 
order by a.sample_time ;