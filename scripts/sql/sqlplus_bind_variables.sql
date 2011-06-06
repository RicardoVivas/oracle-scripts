SQL*Plus bind variables

SQL*Plus bind variables can be declared outwith PL/SQL blocks. 
I find this useful if I want to put values into a SQL statement which uses bind variables and I don't want the optimizer to change the execution plan;
 (it will almost certainly do so if you transpose the bind variables with literal values.)

SQL> var gr1 number;
SQL> var gr2 varchar2(20);
SQL> exec :gr1 := 7369;
SQL> exec :gr2 := 'GARRY';
SQL> print
       GR1
----------
      7369
GR2
--------------------------------
GARRY

SQL> select :gr1, :gr2 from dual;
      :GR1 :GR2
---------- --------------------------------
      7369 GARRY

SQL> select * from scott.emp where empno = :gr1;
     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7369 SMITH      C
      
      
      
But this wont allow you passing a date type value.
Another way is to use the pl/sql

SQL>
SQL> declare
2 v_dts timestamp(3) := systimestamp;
3 v_count integer;
4 begin
5 select count(*) as example2
6 into v_count
7 from x
8 where created_dts = v_dts;
9 end;
10 /       
     
SQL> declare
2 v_date date := sysdate;
3 v_count integer;
4 begin
5 select count(*) as example1
6 into v_count
7 from x
8 where created_date = v_date;
9 end;
10 / 



To view bind information:

select name, position, datatype_string, was_captured, value_string,anydata.accesstimestamp(value_anydata) from v$sql_bind_capture where sql_id in ('2avwvgg1qp025','936pz56dqmpdc', '9kvty17uujyva') ;


 
