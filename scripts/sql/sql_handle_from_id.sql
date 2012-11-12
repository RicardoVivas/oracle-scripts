SELECT sql_handle, plan_name
FROM dba_sql_plan_baselines
WHERE signature IN (
  SELECT exact_matching_signature FROM v$sql WHERE sql_id='&SQL_ID'
)