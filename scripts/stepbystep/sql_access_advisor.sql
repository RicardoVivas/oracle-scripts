DECLARE
  task_id number;
  taskname varchar2(30) := 'SQLACCESS_TEST';
  sts_name varchar2(256) := 'SQLACCESS_STS';
  sts_cursor dbms_sqltune.sqlset_cursor;

BEGIN
  dbms_advisor.create_task(DBMS_ADVISOR.SQLACCESS_ADVISOR, task_id, taskname);

  /* Select all statements in the cursor cache. */
  dbms_sqltune.create_sqlset(sts_name, 'Obtain workload from cursor cache');
  
  OPEN sts_cursor FOR SELECT VALUE(P)   FROM TABLE(dbms_sqltune.select_cursor_cache) P;
     dbms_sqltune.load_sqlset(sts_name, sts_cursor);
  CLOSE sts_cursor;
 
  /* Link STS Workload to Task */
  dbms_advisor.add_sqlwkld_ref ( taskname, sts_name, 1);

  /* Set STS Workload Parameters */
  dbms_advisor.set_task_parameter(taskname, 'SQL_LIMIT','25');
  dbms_advisor.set_task_parameter(taskname, 'ANALYSIS_SCOPE','ALL');
  dbms_advisor.set_task_parameter(taskname, 'TIME_LIMIT',10000);
  dbms_advisor.set_task_parameter(taskname, 'MODE','LIMITED');
 
  /* Execute Task */
  dbms_advisor.execute_task(taskname);
END;
/

-- Display the resulting script.
SET LONG 100000
SET PAGESIZE 50000
SELECT DBMS_ADVISOR.get_task_script('SQLACCESS_TEST') AS script FROM   dual;
/