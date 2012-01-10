drop table t1;
 
create table t1 as
select
   o.owner,
   o.object_name    object_name,
   o.object_type    object_type,
   count(1)         num_blocks_in_buffer
from
   dba_objects  o,   v$bh   bh
where   o.object_id  = bh.objd
--and   o.owner not in ('WMSYS')
group by    o.owner,   o.object_name,   o.object_type
order by   count(1) desc;


select
   substr(t1.owner, 1,10) "owner",
   substr(object_name,1, 30),
   --Assume the block size is 8K
   round(num_blocks_in_buffer * 8/1024) Size_MB ,  
   sum(blocks) "Total_Blocks",
   round((num_blocks_in_buffer/decode(sum(blocks), 0, .001, sum(blocks)))*100) "Percentage in Buffer",
   num_blocks_in_buffer,
   object_type
from   t1,   dba_segments s
where   s.segment_name = t1.object_name
and  num_blocks_in_buffer > 100 
group by    t1.owner,   object_name,   object_type,   num_blocks_in_buffer
order by   num_blocks_in_buffer desc;

select count(*) "num_blocks_in_buffer" , round(count(*) * 8 / 1024) size_MB from v$bh;
