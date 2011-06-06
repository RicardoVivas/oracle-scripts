create table child 
as
with generator as (
  select --+ materialize 
  rowid id
  from all_objects 
  where rownum < 5000
)
select 
 trunc(dbms_random.value(1, 1001)) account,
 trunc(sysdate - 10) + rownum/1000 tx_time,
 round(dbms_random.value(5,50), 2) debit,
 rpad ('x', 1000)
from generator v1,
     generator v2
where
   rownum <= 10000;

alter table child add constraint c_pk  primary key (account, tx_time);

create table parent as
select  account, min(tx_time) first_tx_time, rpad('x', 300) padding
from child
group by account 
order by min(tx_time);

alter table parent add constraint p_pk primary key(account);

alter table child 
