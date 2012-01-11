rem
rem	Script:		join_card_new_01.sql
rem	Author:		Jonathan Lewis
rem	Dated:		Nov 2005
rem	Purpose:	
rem
rem	Last tested 
rem		10.1.0.4
rem		 9.2.0.6
rem		 8.1.7.4
rem
rem	Notes:
rem	From work done by Alberto Dell'Era.
rem	How join cardinality really works.
rem
rem	The book says (ch 10, p.303-304):
rem	For a simple one-column equality, do a cartesian join 
rem	based on the filter predicates and then apply the more 
rem	selective of
rem		t1.joincol = {constant}
rem		or
rem		t2.joincol = {constant}
rem
rem	However, the selectivity of 'column = {constant}' is more
rem	subtle than simply looking at the base selectivity of the
rem	columns as indicated by user_tab_columns.num_distinct.
rem
rem	Consider the following experiment
rem		I have 50 balls in a bag, each with a different 
rem		number painted on it.
rem	
rem		I select a ball from the bag, take a note of the 
rem		number, and put the ball back.
rem
rem		I repeat this action 100 times.
rem
rem		How many different numbers will I have written down ?
rem
rem	The answer to the specific question for one run of the 
rem	experiment is not something I can predict. It could be 
rem	just one (which you would probably think very unlikely) 
rem	or it might be 50 (which you might think is a little lucky).
rem
rem	However, repeat the experiment thousands of times, and 
rem	you will find that the average number of distinct values
rem	converges to a constant. This is a well-known result in
rem	probability theory, and the formula for the average is
rem	as follows:
rem
rem		Let N be the number of balls (initial distinct values)
rem		Let n be the number of times you pick a ball
rem
rem	The expected (or average) number of distinct values in one
rem	run of the experiment is:
rem		N* ( 1- (1-1/N)^n )	(where ^ means 'to the power of)
rem
rem	In our example:
rem		N = 50, n = 100
rem		50 * ( 1 - (1 - 1/50)^100 ) =
rem		50 * ( 1 - (49/50)^100 )  =
rem		50 * ( 1 - 0.13262) =
rem		50 * 0.86738 =
rem		43.36
rem
rem	Why introduce this digression ?
rem	Because this is the approach the CBO takes on a join.
rem	Consider:
rem		t1.joincol = {constant}
rem
rem	N is the number of possible values for t1.joincol (num_distinct)
rem	n is the number of rows that we will be checking  (filtered cardinality)
rem
rem	The formula gives us the expected number of distinct values
rem	of t1.joincol that "might realistically appear" before we try
rem	to perform the join. It is this expected value that the CBO 
rem	uses as the 'effective num_distinct' of t1.joincol, from which 
rem	it derives the join cardinality of the join.
rem
rem	So the CBO applies the formula,takes the ceiling() of the result
rem	(in our case 43.36 becomes 44) and feeds this into the formula 
rem	for join selectivity as an 'adjusted num_distinct'.
rem
rem	Since there are two ways to look at the join condition, the CBO
rem	performs the calculation for both ends of the join, and uses the 
rem	larger 'adjusted num_distinct'.
rem
rem	Join Selectivity =
rem		((num_rows(t1) - num_nulls(t1.c1)) / num_rows(t1)) *
rem		((num_rows(t2) - num_nulls(t2.c2)) / num_rows(t2)) /
rem		greater(num_distinct(t1.c1), num_distinct(t2.c2))
rem
rem	Looking at the original (reformatted) MetaLink formula above,
rem	we can see that we don't need to change this formula merely
rem	use the 'adjusted num_distict' rather than the value we find
rem	in user_tab_columns.num_distinct. Moreover, in many cases the 
rem	'correction factor' is very small so the (slightly misleading)
rem	formula given on MetaLink is often likely to produce a result
rem	that is very close to the correct value.
rem
rem	Note, particularly, even for fairly small values of N and n,
rem	the factor ( ( 1 - 1/N)^n ) gets very small very quickly - try
rem	N = 250 (distinct values), n = 1000 (filtered cardinality)
rem	and the "correction" factor is less than 2%
rem
rem	Short description:
rem	------------------
rem	Select a random sample of size n, with replacement, from the
rem	population D = {1,2,3,4,...N}
rem
rem	The average (expected) number of distinct values is given by 
rem		N( 1 - (1 - 1/N)^n )
rem	In this case:
rem		N is the number of distinct values for the column
rem		n is the size of the pick-list - the filtered cardinality
rem	We use this formula to generate an 'effective num_distinct' for
rem	the columns in the join condition
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

*/

drop table generator;
create table generator as
select
	rownum 	id
from	all_objects 
where	rownum <= 2000
;


begin
	begin		execute immediate 'purge recyclebin';
	exception	when others then null;
	end;

	begin		dbms_stats.delete_system_stats;
	exception	when others then null;
	end;

	begin		execute immediate 'alter session set "_optimizer_cost_model"=io';
	exception	when others then null;
	end;
end;
/

create table t1
as
/*
with generator as (
	select	--+ materialize
		rownum 	id
	from	all_objects 
	where	rownum <= 5000
)
*/
select
	-- ordered use_nl(v2)
	mod(rownum,20)		twenty,
	mod(rownum,30)		thirty,
	mod(rownum,40)		forty,
	mod(rownum,50)		fifty,
	mod(rownum,60)		sixty,
	mod(rownum,100)		onehundred,
	mod(rownum,200)		twohundred,
	rpad('x',100)		padding
from
	generator	v1,
	generator	v2
where
	rownum <= 10000
;

create table t2
as
/*
with generator as (
	select	--+ materialize
		rownum 	id
	from	all_objects 
	where	rownum <= 5000
)
*/
select
	-- ordered use_nl(v2)
	mod(rownum,25)		twentyfive,
	mod(rownum,35)		thirtyfive,
	mod(rownum,45)		fortyfive,
	mod(rownum,55)		fiftyfive,
	mod(rownum,65)		sixtyfive,
	mod(rownum,100)		onehundred,
	mod(rownum,200)		twohundred,
	rpad('x',100)		padding
from
	generator	v1,
	generator	v2
where
	rownum <= 10500
;

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

begin
	dbms_stats.gather_table_stats(
		ownname		 => user,
		tabname		 =>'T2',
		cascade		 => true,
		estimate_percent => null,
		granularity      => 'DEFAULT',
		method_opt 	 => 'for all columns size 1'
	);
end;
/

spool join_card_new_01

set autotrace traceonly explain

prompt
prompt	t1 = 50 / t2 = 55
prompt	Join cardinality driven by t1
prompt

select count(*) 
from
	t1, t2
where
	t1.onehundred = t2.onehundred
and	t1.fifty = 0
and	t2.fiftyfive = 0
;

/*

Execution Plan (9.2.0.6)
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=CHOOSE (Cost=60 Card=1 Bytes=12)
   1    0   SORT (AGGREGATE)
   2    1     HASH JOIN (Cost=60 Card=439 Bytes=5268)
   3    2       TABLE ACCESS (FULL) OF 'T2' (Cost=30 Card=191 Bytes=1146)
   4    2       TABLE ACCESS (FULL) OF 'T1' (Cost=29 Card=200 Bytes=1200)

*/

rem
rem	Filtered cardinality of t1:	10,000/50 = 200.00
rem	Filtered cardinality of t2:	10,500/55 = 190.91
rem	
rem	t1.onehundred - expected number of distinct values in filtered rows
rem		N * (1 - (1 - 1/N)^n ) = 
rem		100 * (1 - (99/100)^200 ) = 87
rem		Implied selectivity 1/87 = 0.011494
rem
rem	t2.onehundred - expected number of distinct values in filtered rows
rem		N * ( 1 - (1 - 1/N)^n ) = 
rem		100 * (1 - (99/100)^191 ) = 86
rem		Implied selectivity 1/86 = 0.011628
rem
rem	We will use 0.011494 as the selectivity
rem
rem	Cartesian cardinality after filtering is
rem		10,000/50 * 10,500/55 = 38,181
rem
rem	Final cardinality = 38,181 * 0.011494 = 439
rem

prompt
prompt	t1 = 60 / t2 = 55
prompt	Join cardinality driven by t2
prompt

select count(*) 
from
	t1, t2
where
	t1.onehundred = t2.onehundred
and	t1.sixty = 0
and	t2.fiftyfive = 0
;

/*

Execution Plan (9.2.0.6)
----------------------------------------------------------
   0      SELECT STATEMENT Optimizer=CHOOSE (Cost=60 Card=1 Bytes=12)
   1    0   SORT (AGGREGATE)
   2    1     HASH JOIN (Cost=60 Card=370 Bytes=4440)		-- 8i had 371
   3    2       TABLE ACCESS (FULL) OF 'T1' (Cost=29 Card=167 Bytes=1002)
   4    2       TABLE ACCESS (FULL) OF 'T2' (Cost=30 Card=191 Bytes=1146)

*/

rem
rem	Filtered cardinality of t1:	10,000/60 = 166.67
rem	Filtered cardinality of t2:	10,500/55 = 190.91
rem	
rem	t1.onehundred - expected number of distinct values in filtered rows
rem		N * ( 1 - (1 - 1/N)^n ) = 
rem		100 * ( 1 - (99/100)^167 ) = 82
rem		Implied selectivity 1/82 = 0.012195
rem
rem	t2.onehundred - expected number of distinct values in filtered rows
rem		N * ( 1 - (1 - 1/N)^n ) = 
rem		100 * ( 1 - (99/100)^191 ) = 86
rem		Implied selectivity 1/86 = 0.011628
rem
rem	We will use 0.011628 as the selectivity
rem
rem	Cartesian cardinality after filtering is
rem		10,000/60 * 10,500/55 = 31,818
rem
rem	Final cardinality = 31,818 * 0.011628 = 370
rem		Note - this example suggests that rounding in 9i occurs
rem		only after the Cartesian cardinality has been calculated
rem		not on the individual filtered cardinalities. But that 8i
rem		rounds the individual cardinalities and the multiplies.
rem

set autotrace off

spool off




set doc off
doc

Recreate table t2 with 15,000 rows and check the following:

select count(*) 
from
	t1, t2
where
	t1.onehundred = t2.twohundred
and	t1.thirty = 0
and	t2.thirtyfive = 0
;

rem
rem	Rows in t1	 10,000
rem	Rows in t2	 15,000
rem	Column names imply num_distinct
rem
rem	Filtered cardinality of t1:	10,000/30 = 333.33	333
rem	Filtered cardinality of t2:	15,000/35 = 428.57	429
rem	
rem	t1.onehundred - expected number of distinct values in filtered rows
rem		N * ( 1 - (1 - 1/N)^n ) = 
rem		100 * ( 1 - (99/100)^333 ) = 97
rem		Implied selectivity 1/97 = 0.010309
rem
rem	t2.twohundred - expected number of distinct values in filtered rows
rem		N * ( 1 - (1 - 1/N)^n ) = 
rem		200 * ( 1 - (199/200)^429 ) = 177
rem		Implied selectivity 1/177 = 0.00565
rem
rem	We will use 0.00565 as the selectivity
rem
rem	Cartesian cardinality after filtering is
rem		10,000/30 * 15,000/35 = 142,857
rem
rem	Final cardinality = 142,857 * 0.00565 = 807
rem
rem	This is pretty close, but the cardinality we get from
rem	autotrace is 803, which is 142,857 / 178. Our expected
rem	number of distinct values is out by one.
rem		a) there is an extra adjustment.
rem		b) the internal arithmetic uses an iterative calculation
rem		   to avoid overflow, and gets a slightly incorrect answer
rem		c) other
rem

#
