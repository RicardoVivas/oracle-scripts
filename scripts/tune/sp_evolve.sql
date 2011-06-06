set serveroutput on
set long 100000
Declare 
  output_report clob;
begin
  output_report := dbms_spm.evolve_sql_plan_baseline(sql_handle => '&sql_handle');
  dbms_output.put_line(output_report);
end;
/