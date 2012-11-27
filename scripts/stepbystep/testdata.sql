create table t1
as
with generator as (
    select  --+ materialize
        rownum id
    from dual
    connect by
        level <= 10000
)
select
    rownum                          n1,
    case when mod(rownum,2) = 0 then rownum end     n2,
    lpad(rownum,10,'0')                 v1,
    case when mod(rownum,2) = 0 then rpad('x',10) end   v2,
    rpad('x',100)                       padding
from
    generator   v1,
    generator   v2
where
    rownum <= 100000
;
 
begin
    dbms_stats.gather_table_stats(
        ownname      => user,
        tabname      =>'T1',
        method_opt   => 'for all columns size 1'
    );
end;
/
 
explain plan for
create index t1_v1 on t1(v1);
 
select * from table(dbms_xplan.display);
