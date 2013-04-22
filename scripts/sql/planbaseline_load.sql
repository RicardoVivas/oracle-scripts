DECLARE
  plan_loaded  PLS_INTEGER;
BEGIN
  plan_loaded := DBMS_SPM.load_plans_from_cursor_cache(sql_id => '&sql_id', plan_hash_value => '&plan_hash_value', fixed=>'YES', enabled=>'YES');
END;