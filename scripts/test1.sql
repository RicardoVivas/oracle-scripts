-- Test merge and multiple insert

create table d20 as select * from dept_emp
create table d40 as select * from dept_emp

insert all 
when deptno=20 then into d20(deptno,dname,ename) values (deptno,dname,ename)
when deptno=30 then into d30(deptno,dname,ename) values (deptno,dname,ename)
when deptno=40 then into d40(deptno,dname,ename) values (deptno,dname,ename)
select * from dept_emp

merge into d20 d using dept  e on (e.deptno =20 )
when matched      then update set d.dname='its'
when not matched  then insert   (d.deptno,d.dname) values(e.deptno,e.dname);


-- Test DML on view

create or replace view dept_emp_nocheck
as 
select a.empno,a.ename,a.deptno,b.dname 
from emp a, dept b
where a.deptno=b.deptno;

create or replace view dept_emp_check
as 
select a.empno,a.ename,a.deptno,b.dname 
from emp a, dept b
where a.deptno=b.deptno
with check option;

--succeed
update dept_emp_nocheck set deptno=20 where empno=7367;
--fail: cannot update join column
update dept_emp_check set deptno=10 where empno=7367;

--succeed:
insert into dept_emp_nocheck (empno,ename,deptno) values(6666,'hongfeng',10);
--fail:insert statement cannot refer to any columns of the non-key-preserved table 
insert into dept_emp_nocheck (empno,ename,deptno,dname) values(6666,'hongfeng',40,'ITS');

-- rank,dense_rank, keep function
select deptno, avg(sal),count(*), (rank(1000) within group (order by sal nulls first)) from emp group by deptno
select count(*),count(sal) from emp
select count(*) keep (dense_rank first order by (hiredate)) first from emp group by deptno
