select  sql_text,  creator, created, last_execu\zted, enabled, accepted, fixed, sql_handle, plan_name from dba_sql_plan_baselines order by sql_handle desc;