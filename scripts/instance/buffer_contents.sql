set echo off
clear screen

 -- The following query assumes the block size is 8K
select
   substr(t1.owner, 1,10) "owner",
   substr(object_name,1, 30),
   object_type,
   round(num_blocks_in_buffer * 8/1024) Size_MB ,  
   round(sum(blocks * 8/1024)) "Total_Size",
   round((num_blocks_in_buffer/decode(sum(blocks), 0, .001, sum(blocks)))*100) "Cached %"
from 
(
 select
   o.owner,
   o.object_name    object_name,
   o.object_type    object_type,
   count(1)         num_blocks_in_buffer
 from
  dba_objects o, 
  v$bh bh
 where   
  o.object_id  = bh.objd
  and o.owner not in ('SYS','SYSTEM')
  group by 
   o.owner, o.object_name, o.object_type
) t1,  
  dba_segments s
where   
s.segment_name = t1.object_name
and  num_blocks_in_buffer > 1 
group by    
t1.owner, object_name, object_type, num_blocks_in_buffer
order by 6;
