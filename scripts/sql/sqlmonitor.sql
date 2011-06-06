select  username, 
round (elapsed_time/1000/1000) elapsed_sec, round(cpu_time/1000/1000) cpu_sec,  round(user_io_wait_time/1000/1000) as "user_io_wait_sec",
round(buffer_gets/1024/1024, 1) as "buffer_get_M", 
physical_write_bytes, round(physical_read_bytes/1024/1024,1) as "physical_read_mb",
last_refresh_time, sql_exec_start, sid, session_serial#, process_name, 
sql_id,  sql_plan_hash_value, status,program, sql_text,  binds_xml
from 
v$sql_monitor where  last_refresh_time > sysdate - 0.5 order by last_refresh_time desc;