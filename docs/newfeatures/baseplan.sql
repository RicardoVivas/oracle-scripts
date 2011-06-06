select * from table (dbms_xplan.display_sql_plan_baseline (sql_handle =>  'SYS_SQL_0df1c6b93b4c08d1'))

dbms_spm.load_plans_from_cursor_cache (sql_id=>'', plan_hash_value => '')

dbms_spm.drop_sql_plan_baseline (sql_handle =>'' , plan_name => '');