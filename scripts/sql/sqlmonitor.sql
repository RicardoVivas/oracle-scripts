clear screen

select  
username, 
status,
round (elapsed_time/1000/1000) elap_sec, 
round(cpu_time/1000/1000) cpu_sec,  
round(user_io_wait_time/1000/1000) as "io_wait_sec",
round(buffer_gets/1024/1024, 1) as "buffer_get_mb", 
round(physical_write_bytes/1024/1024,1) as "phy_w_mb",
round(physical_read_bytes/1024/1024,1) as "phy_r_mb",
last_refresh_time, 
sql_exec_start, 
sid, session_serial#, process_name, 
sql_id,  sql_plan_hash_value, 
program, 
sql_text,  binds_xml
from 
v$sql_monitor where  last_refresh_time > sysdate - 1/24 
order by last_refresh_time desc;