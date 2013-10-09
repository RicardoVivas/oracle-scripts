select sysdate, last_active_time, 
executions, 
round(disk_reads/executions)  disk_read_per_exec, 
round(buffer_gets/executions) buffer_get_per_exec,
round(rows_processed/executions) rows_per_exec, 
round(elapsed_time/1000/executions) elapse_ms_per_exec, 
sql_text from v$sqlstats where sql_id='&sql_id';