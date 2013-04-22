-- Use planbaseline_display_from_sqlid to get the plan name
DECLARE
  plan_loaded  PLS_INTEGER;
BEGIN
  plan_loaded := dbms_spm.alter_sql_plan_baseline(plan_name => '&plan_name', attribute_name => 'fixed', attribute_value => 'YES');
END;