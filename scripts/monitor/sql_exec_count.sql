## Check execution count of various type of SQLs

drop table uow_sqlexec purge;

create table uow_sqlexec 
as
select sql_id, 
 child_number, command_type, parsing_schema_name,
 fetches, executions, rows_processed, 
 DISK_READS, buffer_gets, 
 physical_read_bytes, physical_write_bytes, sysdate log_time
from v$sql
where last_active_time > sysdate - 0.25/24;


pause wait 30 seconds before hit any key ...

drop table uow_sqlexec_change purge;
create table uow_sqlexec_change 
as
select b.sql_id, 
 b.child_number, b.command_type, b.parsing_schema_name,
 (b.fetches - a.fetches)/((sysdate - log_time) * 3600 * 24) fetches, 
 (b.executions - a.executions)/((sysdate - log_time) * 3600 * 24) executions,
 (b.rows_processed - a.rows_processed)/((sysdate - log_time) * 3600 * 24) rows_processed, 
 (b.DISK_READS - a.disk_reads)/((sysdate - log_time) * 3600 * 24) disk_reads, 
 (b.buffer_gets - a.buffer_gets)/((sysdate - log_time) * 3600 * 24) buffer_gets, 
 (b.physical_read_bytes - b.physical_read_bytes)/((sysdate - log_time) * 3600 * 24) physical_read_bytes, 
 (b.physical_write_bytes - a.physical_write_bytes)/((sysdate - log_time) * 3600 * 24) physical_write_bytes , 
 round((sysdate - log_time) * 3600 * 24) time_change
from 
 v$sql b, uow_sqlexec a
where 
 a.sql_id = b.sql_id and 
 a.child_number = b.child_number and 
 last_active_time > sysdate - 0.25/24;

select 
 decode(command_type, 1, 'CREATE', 2, 'INSERT', 3, 'SELECT', 6, 'UPDATE', 7, 'DELETE', 26, 'LOCK TAB', 47, 'FUNC', 170, 'PROC', 189, 'MERGE') COMMAND,
 parsing_schema_name,  
 round(sum(executions)) exc_per_sec, 
 round(sum(buffer_gets)) buffer_gets_sec,
 round(sum(fetches)) fetches_per_sec,
 round(sum(rows_processed)) rows_processed,
 round(sum(disk_reads)) disk_reads
from 
 uow_sqlexec_change
group by ROLLUP(command_type, parsing_schema_name) 
having sum(executions) > 0;
--order by  round(executions) desc, parsing_schema_name;

