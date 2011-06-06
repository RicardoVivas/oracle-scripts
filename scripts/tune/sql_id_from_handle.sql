select sql_id from v$sql where exact_matching_signature in (
SELECT signature
FROM dba_sql_plan_baselines
WHERE sql_handle = &sql_handle);