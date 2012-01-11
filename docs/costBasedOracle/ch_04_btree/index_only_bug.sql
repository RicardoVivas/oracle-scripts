rem
rem	Script:		index_only_bug.sql
rem	Author:		Jonathan Lewis
rem	Dated:		Nov 2005
rem	Purpose:	
rem
rem	Last tested 
rem		10.2.0.1
rem		10.1.0.4
rem		 9.2.0.6
rem		 8.1.7.4
rem
rem	Notes:
rem	I have heard suggestions that Oracle 9.2 costs for 
rem	index pre-fetching. This doesn't appear to be true.
rem	We can check this by noting two things at once for
rem	the following test case:
rem		a) The cost of the query is blevel + leaf_blocks
rem		b) The 10053 trace says 'prefetching is on for T1_I1'
rem
rem	Co-incidentally, whilst testing the claim about costing
rem	and prefetching, I also happened to discover that the
rem	cost of this example query adds the cost of the table 
rem	sort to the query, despite not the fact that the query
rem	has used the index to avoid doing a sort.  (This is true
rem	for 8.1.7.4 and 9.2.0.6, but is fixed by 10.1.0.4)
rem
rem	The query rewrite enabled = true is for 8i, which needs
rem	the parameter set to use the simple function-based index. 
rem	(Because it uses a built-in function, we can run with 
rem	query_rewrite_integrity = enforced, the default, rather 
rem	than having to switch to trusted).
rem

start setenv
set timing off

alter session set query_rewrite_enabled = true;

execute dbms_random.seed(0)

drop table t1;

/*

rem
rem	8i code to build scratchpad table
rem	for generating a large data set
rem

drop table generator;
create table generator as
select
	rownum 	id
from	all_objects 
where	rownum <= 2000
;

*/

begin
	begin		execute immediate 'purge recyclebin';
	exception	when others then null;
	end;

	begin		execute immediate 'execute dbms_stats.delete_system_stats';
	exception	when others then null;
	end;

	begin		execute immediate 'alter session set "_optimizer_cost_model"=io';
	exception	when others then null;
	end;
end;
/


create table t1
as
with generator as (
	select	--+ materialize
		rownum 	id
	from	all_objects 
	where	rownum <= 5000
)
select
	/*+ ordered use_nl(v2) */
	lpad(rownum,30)	id,
	rownum		n1,
	rpad('x',100)	padding
from
	generator	v1,
	generator	v2
where
	rownum <= 100000
;

alter table t1 add constraint t1_pk primary key(id);
create index t1_i1 on t1(lpad(n1,30));

begin
	dbms_stats.gather_table_stats(
		ownname		 => user,
		tabname		 =>'T1',
		cascade		 => true,
		estimate_percent => null,
		granularity      => 'DEFAULT',
		method_opt 	 => 'for all columns size 1'
	);
end;
/

spool index_only_bug

select
	index_name, blevel, leaf_blocks
from
	user_indexes
where
	table_name = 'T1'
;


set autotrace traceonly explain

prompt
prompt	Default on declared varchar2(30)
prompt

select
	id
from	t1
order by
	id
;

prompt
prompt	Hinted to tablescan on declared varchar2(30)
prompt

select	/*+ full(t1) */
	id
from	t1
order by
	id
;

prompt
prompt	Default on functional index returning varchar2(30)
prompt	Uses a fast full scan on 10g
prompt

select
	lpad(n1,30)
from	t1
where
	lpad(n1,30) is not null
order by
	lpad(n1,30)
;

prompt
prompt	Hinted to full scan on functional index returning varchar2(30)
prompt	.	8i can't use the index unless query rewrite is enabled
prompt	.	9i Adds a sort cost to the total (as does 8i)
prompt	.		"Pure" sort cost from above is 513 - 299 = 214
prompt	.		Total cost below is 801 = 587 + 214
prompt	.	10g Total cost = full scan cost
prompt

select
	/*+ index(t1) */
	lpad(n1,30)
from	t1
where
	lpad(n1,30) is not null
order by
	lpad(n1,30)
;


set autotrace off

spool off

set doc off
doc


Sample from 10053 trace for 9.2.0.6
-----------------------------------

SINGLE TABLE ACCESS PATH
  TABLE: T1     ORIG CDN: 100000  ROUNDED CDN: 100000  CMPTD CDN: 100000
  Access path: index (no sta/stp keys)
      Index: T1_I1
  TABLE: T1
      RSC_CPU: 0   RSC_IO: 587
  IX_SEL:  1.0000e+000  TB_SEL:  1.0000e+000
  BEST_CST: 587.00  PATH: 4  Degree:  1
    SORT resource      Sort statistics
      Sort width:           58 Area size:      208896 Max Area size:    10485760   Degree: 1
      Blocks to Sort:      196 Row size:           16 Rows:     100000
      Initial runs:          2 Merge passes:        1 IO Cost / pass:        232
      Total IO sort cost: 214
      Total CPU sort cost: 0
      Total Temp space used: 2434000
prefetching is on for T1_I1
Final - All Rows Plan:
  JOIN ORDER: 1
  CST: 801  CDN: 100000  RSC: 801  RSP: 801  BYTES: 500000
  IO-RSC: 801  IO-RSP: 801  CPU-RSC: 0  CPU-RSP: 0


Execution Plan (9.2.0.6)
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=CHOOSE (Cost=801 Card=100000 Bytes=500000)
   1    0   INDEX (FULL SCAN) OF 'T1_I1' (NON-UNIQUE) (Cost=587 Card=100000 Bytes=500000)


#
