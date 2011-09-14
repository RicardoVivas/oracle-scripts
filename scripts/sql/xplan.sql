SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('&sql_id'));

SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR('&sql_id'));




DECLARE
  l_plans_loaded  PLS_INTEGER;
BEGIN
  l_plans_loaded := DBMS_SPM.load_plans_from_cursor_cache(    sql_id => '96khrnxhg5s9j', plan_hash_value => '845507789');
END;