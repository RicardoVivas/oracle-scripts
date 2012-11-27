SELECT t.*
   FROM (
   SELECT sql_handle FROM dba_sql_plan_baselines WHERE signature IN ( SELECT exact_matching_signature FROM v$sql WHERE sql_id='&SQL_ID')   
   ) pb,
        TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(pb.sql_handle, NULL, 'BASIC')) t;