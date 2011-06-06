select b.begin_interval_time, b.end_interval_time,  c.owner, c.object_name, a.logical_reads_delta,  a.physical_reads_delta, a.physical_writes_delta  
from dba_hist_seg_stat a, dba_hist_snapshot b, dba_objects c 
where a.snap_id = b.snap_id and a.obj# = c.object_id 
order by b.end_interval_time desc, c.owner, c.object_name
