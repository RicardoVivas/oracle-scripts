set lin 200;

drop table obj_name purge;
drop sequence seq1;
create sequence seq1;

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
  seq1.nextval/1                        id,
  trunc(sysdate-10) + rownum/1000     tx_time,
  round(dbms_random.value(5, 50),2)   debit,
  rpad('x', 100)                      padding
from 
  generator v1, 
  generator v2
where 
  rownum <= 500000; 
  

create index idx_objname_id on obj_name (id) nologging;

drop table obj_name2 purge;
drop sequence seq2;
create sequence seq2;

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
  seq2.nextval/1                        id,
  trunc(sysdate-10) + rownum/1000     tx_time,
  round(dbms_random.value(5, 50),2)   debit,
  rpad('x', 100)                      padding
from 
  generator v1, 
  generator v2
where 
  rownum <= 100000;

create index idx_objname2_id on obj_name2 (id ) nologging;

execute dbms_stats.gather_table_stats(ownname=> user, tabname=>'obj_name', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=> 'for all indexed columns size 1',cascade => TRUE);
execute dbms_stats.gather_table_stats(ownname=> user, tabname=>'obj_name2',estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=> 'for all indexed columns size 1',cascade => TRUE);

select table_name, NUM_ROWS, blocks from user_tables where table_name in ('OBJ_NAME', 'OBJ_NAME2') order by table_name;
select index_name, NUM_ROWS, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR from user_indexes where table_name in ('OBJ_NAME', 'OBJ_NAME2') order by table_name;
select segment_name, bytes/1024/1024 as MBytes from dba_segments where segment_name in ('OBJ_NAME', 'OBJ_NAME2') ;

set timing on;
set autotrace trace;
select a.*, b.* from obj_name a        join obj_name2 b on a.id = b.id;
select a.*, b.* from obj_name a left   join obj_name2 b on a.id = b.id;
select a.*, b.* from obj_name a right  join obj_name2 b on a.id = b.id;
select a.*, b.* from obj_name a full   join obj_name2 b on a.id = b.id;
select /*+ use_nl (a,b) */ a.*, b.* from obj_name a        join obj_name2 b on a.id = b.id;

set autotrace off;
exit;

set doc off
doc

For normal join, use MERGE JOIN between two tables. table OBJ_NAME is via IFS, table OBJ_NAME2 FTS
for left join, use HASH JOIN RIGHT OUTER,  oracle transformed OBJ_NAME2 join  OBJ_NAME
for left join, use HASH JOIN OUTER,        OBJ_NAME2 join  OBJ_NAME
for outer join, use HASH JOIN FULL OUTER,  still OBJ_NAME2 join  OBJ_NAME

Small table join big tables

Not nested loop here.

If you force netsted loop, then "consistent gets" is bigger than hash join 

#


