rem
rem	Script:		index_bind_sel.sql
rem	Author:		Jonathan Lewis
rem	Dated:		Dec 2005
rem	Purpose:	Indexes and bind variables
rem
rem	Last tested:
rem		10.1.0.4
rem		 9.2.0.6
rem		 8.1.7.4
rem
rem	This is a simple demonstration of an observation
rem	made by Boris Dali that the selectivity figures
rem	used for range scans in indexes do not obey the
rem	normal 5% and (5% * 5%) rule for tables.
rem
rem	For the purposes of calculating the number of leaf
rem	blocks to be visited, Oracle uses some other calculation
rem	that seems to tend to a limit of 0.009 for an open range
rem		(col > {const}) 
rem	and 0.0045 for a closed range 
rem		(col between {const1} and {const2}
rem
rem	This can best be seen in the 10053 trace files.
rem	
rem	To make this work for 9i and 10g, we have to set
rem	the hidden parameter "_optim_peek_user_binds"=false.
rem


start setenv
set timing off
set feedback off

execute dbms_random.seed(0)

drop table t1;

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


create table t1 (
	rep_col		not null,
	id		not null,
	small_vc,
	padding	
)
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
	trunc(sqrt(rownum-1)),
	rownum-1,
	lpad(rownum-1,10),
	rpad('x',50)
from
	generator	v1,
	generator	v2
where
	rownum <= 250000
/


create index t1_i1 on t1(rep_col);

begin
	dbms_stats.gather_table_stats(
		user,
		't1',
		cascade => true,
		estimate_percent => null,
		method_opt => 'for all columns size 1'
	);
end;
.
/


spool index_bind_sel

alter session set "_optim_peek_user_binds"=false;


variable v1 number
variable v2 number

execute :v1 := 150; :v2 := 250

set autotrace on explain
alter session set events '10053 trace name context forever';

select	count(*) 
from 	t1
where	rep_col between to_number(:v1) and to_number(:v2)
;


select	count(*) 
from 	t1
where	rep_col > to_number(:v1)
;


alter session set events '10053 trace name context off';
set autotrace off

spool off

set doc off
doc

Sample from the 10g trace files for the rep_col > :bind
-------------------------------------------------------
Note that the selectivity implied by the Computed cardinality
is 1/20 (5%), but when you get down to the penultimate line
the ix_sel for the (index_only) access path is 0.009, not 0.05

SINGLE TABLE ACCESS PATH
  COLUMN:    REP_COL(NUMBER)  Col#: 1      Table: T1   Alias: T1
    Size: 4  NDV: 500  Nulls: 0  Density: 2.0000e-003 Min: 0  Max: 499
  TABLE: T1  Alias: T1     
    Original Card: 250000   Rounded: 12500  Computed: 12500.00  Non Adjusted: 12500.00

                   ^^^^^^                             ^^^^^^^^  12500/250000 = 1/20

  Access Path: table-scan  Resc:  401  Resp:  401
  Access Path: index (index-ffs)
    Index: T1_I1
    rsc_cpu: 0   rsc_io: 81
    ix_sel:  0.0000e+000    ix_sel_with_filters:  1.0000e+000
  Access Path: index-ffs  Resc:  81  Resp:  81
  Access Path: index (index-only)
    Index: T1_I1
    rsc_cpu: 0   rsc_io: 7
    ix_sel:  9.0000e-003    ix_sel_with_filters:  9.0000e-003

  BEST_CST: 7.00  PATH: 4  Degree:  1


Sample from the 10g trace files for the BETWEEN clause
------------------------------------------------------
Similarly, the table selectivity is 1/400 (0.0025), but
the index selectivity for the purposes of costing the 
number of leaf block visits is fixed at 0.0045

SINGLE TABLE ACCESS PATH
  COLUMN:    REP_COL(NUMBER)  Col#: 1      Table: T1   Alias: T1
    Size: 4  NDV: 500  Nulls: 0  Density: 2.0000e-003 Min: 0  Max: 499
  TABLE: T1  Alias: T1     
    Original Card: 250000   Rounded: 625  Computed: 625.00  Non Adjusted: 625.00

                   ^^^^^^                           ^^^^^^  625/250000 = 1/400

  Access Path: table-scan  Resc:  401  Resp:  401
  Access Path: index (index-ffs)
    Index: T1_I1
    rsc_cpu: 0   rsc_io: 81
    ix_sel:  0.0000e+000    ix_sel_with_filters:  1.0000e+000
  Access Path: index-ffs  Resc:  81  Resp:  81
  Access Path: index (index-only)
    Index: T1_I1
    rsc_cpu: 0   rsc_io: 5
    ix_sel:  4.5000e-003    ix_sel_with_filters:  4.5000e-003

  BEST_CST: 5.00  PATH: 4  Degree:  1


#

