rem
rem	Script:		join_card_10.sql
rem	Author:		Jonathan Lewis
rem	Dated:		Sep 2004
rem	Purpose:	Example for "Cost Based Oracle"
rem
rem	Last tested:
rem		10.1.0.4
rem		 9.2.0.6
rem		 8.1.7.4
rem
rem	If we have extreme differences in the number
rem	(or possibly range) of values for two columns
rem	to be joined, we can get some strange results
rem	that still need to be explained.
rem
rem	One feature that makes things difficult is the
rem	rule about: if there is a filter on just one end
rem	of the join, then the predicates from the other
rem	end apply.
rem
rem	Then various other rules about multi-column selectivities
rem	and index selectivities could have an impact.
rem
rem	Then there are various options regarding predicates on
rem	columns with a small number of distinct values, and 
rem	predicates where values can go out of range. 
rem
rem	Update:  Nov 2005. 
rem	Applying the Alberto Dell'Era Deduction:
rem		t1.join1 = t2.join1
rem	and	t1.join2 = t2.join2
rem
rem	Let nj be the filtered cardinality for tableJ
rem	and Nj be the number of distinct values for column colX in tableJ
rem	then the 'adjusted num_distinct' for that column is:
rem		Nj(1 - (1 - 1/Nj) ^ nj)
rem
rem	t1 rows 		= 10,000
rem	t1 filter num distinct	= 10000		-- n1 = 10000 when not filtered
rem	t1 filter num distinct	= 100		-- n1 = 100 when filtered
rem	t1 join1 num distinct 	= 30
rem	t1 join2 num distinct	= 20
rem
rem	t2 rows 		= 10,000
rem	t2 filter num distinct	= 10000		-- n2 = 10000 when not filtered
rem	t2 filter num distinct	= 100		-- n2 = 100 when filtered
rem	t2 join1 num distinct 	= 3668		-- because of random effects
rem	t2 join2 num distinct	= 50
rem
rem	FOR FILTER ON T1:
rem	=================
rem	t1.join1 = t2.join1
rem	t1.join1 - expected number of distinct values in filtered rows
rem		N * (1 - ( 1 - 1/N )^n ) = 
rem		30 * (1 - (29/30)^100 ) = 29
rem
rem	t2.join1 - expected number of distinct values in filtered rows (no filter)
rem		N * ( 1 - ( 1 - 1/N )^n ) = 
rem		3668 * (1 - (3667/3668)^10000 ) = 3,428	-- larger num_distinct
rem
rem	t1.join2 = t2.join2
rem	t1.join2 - expected number of distinct values in filtered rows
rem		N * (1 - ( 1 - 1/N )^n ) = 
rem		20 *  (1 - (19/20)^100 ) = 20
rem
rem	t2.join2 - expected number of distinct values in filtered rows (no filter)
rem		N * ( 1 - ( 1 - 1/N )^n ) = 
rem		50 * ( 1 - (49/50)^10000) = 50		-- larger num_distinct
rem
rem	Filtered Cartesian Cardinality
rem		10,000/100 * 10,000 = 1,000,000
rem	Combined selectivity:
rem		1/ (3,428 * 50) = 1 / 171,400
rem	Final Cardinality
rem		5.83 	-- close, but out by 1 from the actual.
rem			We need a combined cardinality of 139,384
rem			Note - combined selectivity exceeds 10g sanity check
rem
rem	FOR FILTER ON T2:
rem	=================
rem	t1.join1 = t2.join1
rem	t1.join1 - expected number of distinct values in filtered rows
rem		N * ( 1 - ( 1 - 1/N )^n ) = 
rem		30 * ( 1 - (29/30)^10000 ) = 30
rem
rem	t2.join1 - expected number of distinct values in filtered rows (no filter)
rem		N * ( 1 - ( 1 - 1/N )^n ) = 
rem		3668 * ( 1 - (3667/3668)^100 ) = 99		-- larger num_distinct
rem
rem	t1.join2 = t2.join2
rem	t1.join2 - expected number of distinct values in filtered rows
rem		N * ( 1 - ( 1 - 1/N )^n ) = 
rem		20 * ( 1 - (19/20)^10000 ) = 20
rem
rem	t2.join2 - expected number of distinct values in filtered rows (no filter)
rem		N * ( 1 - ( 1 - 1/N )^n ) = 
rem		50 * ( 1 - (49/50)^100 ) = 44		-- larger num_distinct
rem
rem	Filtered Cartesian Cardinality
rem		10,000/100 * 10,000 = 1,000,000
rem	Combined selectivity:
rem		1/ (99 * 44) = 1 / 4,356
rem	Final Cardinality
rem		230 	-- nowhere near, we need a combined cardinality of 2,000
rem

start setenv
set timing off

execute dbms_random.seed(0)

drop table t2;
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

	begin		execute immediate 'begin dbms_stats.delete_system_stats; end;';
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
	where	rownum <= 3000
)
select
	/*+ ordered use_nl(v2) */
	trunc(dbms_random.value(0,  100 ))		filter,
	trunc(dbms_random.value(0,   30 ))		join1,
	trunc(dbms_random.value(0,   20 ))		join2,
	lpad(rownum,10)					v1,
	rpad('x',100)					padding
from
	generator	v1,
	generator	v2
where
	rownum <= 10000
;


rem
rem	Note - join1 has 3,668 distinct values
rem	by the time the table is built because
rem	of the random distribution, and picking
rem	10,000 rows spread over 4,000 values.
rem

create table t2
as
with generator as (
	select	--+ materialize
		rownum 	id
	from	all_objects 
	where	rownum <= 3000
)
select
	/*+ ordered use_nl(v2) */
	trunc(dbms_random.value(0,  100 ))		filter,
	trunc(dbms_random.value(0, 4000 ))		join1,
	trunc(dbms_random.value(0,   50 ))		join2,
	lpad(rownum,10)					v1,
	rpad('x',100)					padding
from
	generator	v1,
	generator	v2
where
	rownum <= 10000
;


begin
	dbms_stats.gather_table_stats(
		user,
		't1',
		cascade => true,
		estimate_percent => null,
		method_opt => 'for all columns size 1'
	);
end;
/

begin
	dbms_stats.gather_table_stats(
		user,
		't2',
		cascade => true,
		estimate_percent => null,
		method_opt => 'for all columns size 1'
	);
end;
/


spool join_card_10

set autotrace traceonly explain

alter session set events '10053 trace name context forever, level 1';

prompt
prompt	Filter on t1	1 row in 100.
prompt

select
	t1.v1, t2.v1
from
	t1, t2
where
	t2.join1 = t1.join1
and	t2.join2 = t1.join2
and	t1.filter = 10
-- and	t2.filter = 10
;

prompt
prompt	Filter on t2	1 row in 100.
prompt

select
	t1.v1, t2.v1
from
	t1, t2
where
	t2.join1 = t1.join1
and	t2.join2 = t1.join2
-- and	t1.filter = 10
and	t2.filter = 10
;

alter session set events '10053 trace name context off';

set autotrace off

spool off

set doc off
doc

9.2.0.6
-------
Execution Plan (9.2.0.6 autotrace. Filter on t1)
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=CHOOSE (Cost=57 Card=7 Bytes=266)
   1    0   HASH JOIN (Cost=57 Card=7 Bytes=266)
   2    1     TABLE ACCESS (FULL) OF 'T1' (Cost=28 Card=100 Bytes=2000)
   3    1     TABLE ACCESS (FULL) OF 'T2' (Cost=28 Card=10000 Bytes=180000)


Execution Plan (9.2.0.6 autotrace. Filter on t2)
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=CHOOSE (Cost=57 Card=500 Bytes=19000)
   1    0   HASH JOIN (Cost=57 Card=500 Bytes=19000)
   2    1     TABLE ACCESS (FULL) OF 'T2' (Cost=28 Card=100 Bytes=2100)
   3    1     TABLE ACCESS (FULL) OF 'T1' (Cost=28 Card=10000 Bytes=170000)


10.1.0.4
--------
Execution Plan (10.1.0.4 autotrace - filter on t1)
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=ALL_ROWS (Cost=92 Card=100 Bytes=3800)
   1    0   HASH JOIN (Cost=92 Card=100 Bytes=3800)
   2    1     TABLE ACCESS (FULL) OF 'T1' (TABLE) (Cost=46 Card=100 Bytes=2000)
   3    1     TABLE ACCESS (FULL) OF 'T2' (TABLE) (Cost=46 Card=10000 Bytes=180000)


Execution Plan (10.1.0.4 autotrace - filter on t2)
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=ALL_ROWS (Cost=92 Card=100 Bytes=3800)
   1    0   HASH JOIN (Cost=92 Card=100 Bytes=3800)
   2    1     TABLE ACCESS (FULL) OF 'T2' (TABLE) (Cost=46 Card=100 Bytes=2100)
   3    1     TABLE ACCESS (FULL) OF 'T1' (TABLE) (Cost=46 Card=10000 Bytes=170000)


#
