set serveroutput on size 1000000 format wrapped

DECLARE
  report_out clob;
  task_id varchar2(50);
  task_name varchar2 (20) := 'test_task1';
   
BEGIN
  DBMS_SQLDIAG.drop_DIAGNOSIS_TASK(task_name=>task_name);
  task_id := DBMS_SQLDIAG.CREATE_DIAGNOSIS_TASK(
    sql_text => 'select from nagios.db_check)',
    task_name=>task_name,
    problem_type=>dbms_sqldiag.problem_type_compilation_error);

   dbms_sqldiag.execute_diagnosis_task(task_name);
 
   report_out := dbms_sqldiag.report_diagnosis_task(task_name,  dbms_sqldiag.type_text);
   dbms_output.put_line('Report : ' || report_out);
END;
/
