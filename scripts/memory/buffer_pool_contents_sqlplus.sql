set pages 999
set lines 80
set lin 200
 
spool blocks.lst
 
ttitle 'Contents of Data Buffers'
 
drop table t1;
 
create table t1 as
select
   o.owner,
   o.object_name    object_name,
   o.object_type    object_type,
   count(1)         num_blocks_in_buffer
from
   dba_objects  o,
   v$bh         bh
where
   o.object_id  = bh.objd
and
   o.owner not in ('SYS','SYSTEM', 'DBSNMP', 'WMSYS')
group by
   o.owner,
   o.object_name,
   o.object_type
order by
   count(1) desc
;
 
 
column c0 heading "owner"                       format a10
column c1 heading "Object|Name"                 format a30
column c2 heading "Object|Type"                 format a15
column c3 heading "Number of|Blocks"            format 999,999,
column c4 heading "Size_MB"                     format 999,999,
column c5 heading "Total|Blocks"                 format 999,999,
column c6 heading "Percentage|of object|data blocks|in Buffer" format 999
 

select
   t1.owner          c0,
   object_name       c1,
   object_type       c2,
   num_blocks_in_buffer        c3,
   --Assume the block size is 8K
   num_blocks_in_buffer * 8/1024 c4 ,  
   sum(blocks) c5,
   round((num_blocks_in_buffer/decode(sum(blocks), 0, .001, sum(blocks)))*100) c6
from
   t1,
   dba_segments s
where
   s.segment_name = t1.object_name
and
 num_blocks_in_buffer > 0 
group by
   t1.owner,
   object_name,
   object_type,
   num_blocks_in_buffer
order by
   num_blocks_in_buffer desc;

spool off
