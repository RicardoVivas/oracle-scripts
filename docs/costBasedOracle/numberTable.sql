execute dbms_random.seed(0);
create table t1 
nologging
as
select
        trunc(dbms_random.value(0,25))  n1,
        rpad('x',40)                    ind_pad,
        trunc(dbms_random.value(0,20))  n2,
        lpad(rownum,10,'0')             small_vc,
        rpad('x',200)                   padding
from
        all_objects
where
        rownum  <= 10000
;

create index t1_i1 on hongfeng.t1(n1, ind_pad, n2) 
nologging
pctfree 91
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
