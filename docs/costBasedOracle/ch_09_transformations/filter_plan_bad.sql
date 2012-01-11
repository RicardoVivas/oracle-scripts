rem
rem	Script:		filter_plan_bad.sql
rem	Author:		Jonathan Lewis
rem	Dated:		Nov 2005
rem	Purpose:	9i lies about some filter execution plans.
rem
rem	Versions tested 
rem		10.1.0.4
rem		 9.2.0.6
rem		 8.1.7.4
rem
rem	Notes:
rem	
rem	We get about 33 rows per block with padding 200
rem	With db_file_multiblock_read set to 8, two reads
rem	will be 16 blocks, which will be about 528 rows.
rem
rem	So delete 500 rows from emp1, put the tablespace
rem	offline then online, and see what happens when you
rem	run the query.
rem
rem	Possibility 1:
rem		Emp2 is scanned first for the average
rem	Possibility 2:
rem		Emp1 has 16 blocks scanned before Emp2 is visited
rem
rem	Possibility 2 is the one that we see. So Oracle is scanning
rem	emp1, and doing a standard filter operation using the scalar
rem	subquery caching technology in all three versions, but only 
rem	reporting it in 8i.
rem
rem	Note that the construction: colx > (subquery) uses the
rem	5% selectivity normally associated with (col > :bind) 
rem

start setenv
set timing off

drop table emp2;
drop table emp1;

begin
	begin		execute immediate 'purge recyclebin';
	exception	when others then null;
	end;

	begin		execute immediate 'begin dbms_stats.delete_system_stats; end;';
	exception 	when others then null;
	end;

	begin		execute immediate 'alter session set "_optimizer_cost_model"=io';
	exception	when others then null;
	end;

end;
/

create table emp1 (
	dept_no		number	not null,
	sal		number,
	emp_no		number,
	padding		varchar2(200),
	constraint e1_pk primary key(emp_no)
);

create table emp2 (
	dept_no		number	not null,
	sal		number,
	emp_no		number,
	padding		varchar2(200),
	constraint e2_pk primary key(emp_no)
);

insert into emp1
select 
	mod(rownum,6),
	rownum,
	rownum,
	rpad('x',200)
from
	all_objects
where
	rownum <= 20000
;

insert into emp2
select 
	mod(rownum,6),
	rownum,
	rownum,
	rpad('x',200)
from
	all_objects
where
	rownum <= 20000
;

begin
	dbms_stats.gather_table_stats(
		ownname			=> user,
		tabname			=> 'EMP1',
		cascade			=> true,
		estimate_percent	=> null, 
		method_opt		=>'for all columns size 1'
	);
end;
/

begin
	dbms_stats.gather_table_stats(
		ownname			=> user,
		tabname			=> 'EMP2',
		cascade			=> true,
		estimate_percent	=> null, 
		method_opt		=>'for all columns size 1'
	);
end;
/

spool filter_plan_bad

set autotrace traceonly explain

prompt
prompt	Baseline query to show the plan
prompt

select
	/*+ no_merge(v) */
	count(*)
from
	(
	select
		outer.* 
	from emp1 outer
	where outer.sal >
		(
			select
				avg(inner.sal) 
	 		from	emp2 inner 
		)
	)	v
;


set autotrace off

delete from emp1 where emp_no<= 500;
commit;

rem
rem	Note - my default tablespace is called test_8k
rem	You may need to change these lines to match your
rem	own default tablespace
rem

alter tablespace test_8k offline;
alter tablespace test_8k online;


alter session set events '10046 trace name context forever, level 8';

prompt
prompt	Query run with 10046 trace enabled.
prompt

select
	/*+ no_merge(v) */
	count(*)
from
	(
	select
		outer.* 
	from emp1 outer
	where outer.sal >
		(
			select
				avg(inner.sal) 
	 		from	emp2 inner 
		)
	)	v
;

alter session set events '10046 trace name context off';

spool off

set doc off
doc

Execution plan 9.2.0.6
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=CHOOSE (Cost=94 Card=1)
   1    0   SORT (AGGREGATE)
   2    1     VIEW (Cost=94 Card=1000)
   3    2       TABLE ACCESS (FULL) OF 'EMP1' (Cost=94 Card=1000 Bytes=5000)
   4    3         SORT (AGGREGATE)
   5    4           TABLE ACCESS (FULL) OF 'EMP2' (Cost=94 Card=20000 Bytes=100000)


Sample Trace 9.2.0.6
--------------------
WAIT #3: nam='db file sequential read' ela= 392 p1=13 p2=9 p3=1		Emp1 seg header
WAIT #3: nam='db file scattered read' ela= 987 p1=13 p2=10 p3=8		Emp1 data
WAIT #3: nam='db file scattered read' ela= 1261 p1=13 p2=18 p3=8	ditto

WAIT #3: nam='db file sequential read' ela= 17526 p1=13 p2=265 p3=1	Emp2 seg header
WAIT #3: nam='db file scattered read' ela= 3435 p1=13 p2=266 p3=8	Emp2 data
WAIT #3: nam='db file scattered read' ela= 1795 p1=13 p2=274 p3=8	ditto
WAIT #3: nam='db file scattered read' ela= 1815 p1=13 p2=282 p3=8	ditto
WAIT #3: nam='db file scattered read' ela= 1825 p1=13 p2=290 p3=8	ditto


Execution Plan 10.1.0.4
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=ALL_ROWS (Cost=188 Card=1)
   1    0   SORT (AGGREGATE)
   2    1     VIEW (Cost=188 Card=1000)
   3    2       TABLE ACCESS (FULL) OF 'EMP1' (TABLE) (Cost=94 Card=1000 Bytes=5000)
   4    3         SORT (AGGREGATE)
   5    4           TABLE ACCESS (FULL) OF 'EMP2' (TABLE) (Cost=94 Card=20000 Bytes=100000)



Sample Trace 10.1.0.4
---------------------
WAIT #41: nam='db file sequential read' ela= 16299 p1=8 p2=649 p3=1
WAIT #41: nam='db file scattered read' ela= 1585 p1=8 p2=650 p3=8
WAIT #41: nam='db file scattered read' ela= 1466 p1=8 p2=658 p3=8

WAIT #41: nam='db file sequential read' ela= 11877 p1=8 p2=905 p3=1
WAIT #41: nam='db file scattered read' ela= 1682 p1=8 p2=906 p3=8
WAIT #41: nam='db file scattered read' ela= 2769 p1=8 p2=914 p3=8
WAIT #41: nam='db file scattered read' ela= 1365 p1=8 p2=922 p3=8
WAIT #41: nam='db file scattered read' ela= 1346 p1=8 p2=930 p3=8


Execution Plan 8.1.7.4
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=CHOOSE (Cost=93 Card=1)
   1    0   SORT (AGGREGATE)
   2    1     VIEW (Cost=93 Card=1000)
   3    2       FILTER
   4    3         TABLE ACCESS (FULL) OF 'EMP1' (Cost=93 Card=1000 Bytes=5000)
   5    3         SORT (AGGREGATE)
   6    5           TABLE ACCESS (FULL) OF 'EMP2' (Cost=93 Card=20000 Bytes=100000)


Sample Trace 8.1.7.4
--------------------
WAIT #1: nam='db file sequential read' ela= 0 p1=8 p2=649 p3=1
WAIT #1: nam='db file scattered read' ela= 0 p1=8 p2=650 p3=8
WAIT #1: nam='db file scattered read' ela= 1 p1=8 p2=658 p3=8

WAIT #1: nam='db file sequential read' ela= 2 p1=8 p2=905 p3=1
WAIT #1: nam='db file scattered read' ela= 0 p1=8 p2=906 p3=8
WAIT #1: nam='db file scattered read' ela= 0 p1=8 p2=914 p3=8
WAIT #1: nam='db file scattered read' ela= 0 p1=8 p2=922 p3=8
WAIT #1: nam='db file scattered read' ela= 0 p1=8 p2=930 p3=8



#
