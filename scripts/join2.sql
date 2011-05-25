rem
rem index with high CF. 
rem Oralce with use hash join
rem

set lin 200;

drop table obj_name purge;

create table obj_name
nologging
as 
with generator as (
 select --+ materialize
    rownum id
  from all_objects
  where rownum <= 5000
)
select 
  trunc(dbms_random.value(1,500000)) id,
  trunc(sysdate-10) + rownum/1000     tx_time,
  round(dbms_random.value(5, 50),2)   debit,
  rpad('x', 100)                      padding
from 
  generator v1, 
  generator v2
where 
  rownum <= 500000; 
  

create index idx_objname on obj_name (id) nologging;

drop table obj_name2 purge;

create table obj_name2
nologging
as 
with generator as (
 select --+ materialize
    rownum id
  from all_objects
  where rownum <= 5000
)
select 
  trunc(dbms_random.value(1, 100000)) id,
  trunc(sysdate-10) + rownum/1000     tx_time,
  round(dbms_random.value(5, 50),2)   debit,
  rpad('x', 100)                      padding
from 
  generator v1, 
  generator v2
where 
  rownum <= 100000;

create index idx_objname2 on obj_name2 (id ) nologging;

execute dbms_stats.gather_table_stats(ownname=> user, tabname=>'obj_name', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=> 'for all indexed columns size 1',cascade => TRUE);
execute dbms_stats.gather_table_stats(ownname=> user, tabname=>'obj_name2',estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=> 'for all indexed columns size 1',cascade => TRUE);

select table_name, NUM_ROWS, blocks from user_tables where table_name in ('OBJ_NAME', 'OBJ_NAME2') order by table_name;
select index_name, NUM_ROWS, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR from user_indexes where table_name in ('OBJ_NAME', 'OBJ_NAME2') order by index_name;
select segment_name, bytes/1024/1024 as MBytes from dba_segments where segment_name in ('OBJ_NAME', 'OBJ_NAME2') ;

set timing on;
set autotrace trace;
select a.*, b.* from obj_name a join obj_name2 b on a.id = b.id;
set autotrace off;
exit;


