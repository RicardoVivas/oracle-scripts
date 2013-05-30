rem See http://czmmiao.iteye.com/blog/1544682

select * from (
       select
          sql_id
          event,
          trim(to_char(p1, 'XXXXXXXXXXXXXXXX')) latch_addr,
          round(ratio_to_report(count(*)) over () * 100) || '%' pct,
          count(*)
       FROM DBA_HIST_ACTIVE_SESS_HISTORY 
WHERE event like 'latch%' 
and  sample_time BETWEEN TO_DATE('22/05/13 22:10:00','DD/MM/YY HH24:MI:SS') AND TO_DATE('22/05/13 22:16:00','DD/MM/YY HH24:MI:SS') 
      group by sql_id, event,p1
      order by count(*) desc
   )
where rownum <= 10;
   
select lpad(replace(to_char(event_p1,'XXXXXXXXX'),' ','0'),16,0) laddr from dual;

select /*+ RULE */
       e.owner ||'.'|| e.segment_name  segment_name,
       e.extent_id  extent#,
       x.dbablk - e.block_id + 1  block#,
       x.tch,
       l.child#
     from
       sys.v$latch_children  l,
       sys.x$bh  x,
       sys.dba_extents  e
     where
       x.hladdr  in ( select lpad(replace(to_char(&event_p1,'XXXXXXXXX'),' ','0'),16,0) laddr from dual) and
       e.file_id = x.file# and
       x.hladdr = l.addr and
       x.dbablk between e.block_id and e.block_id + e.blocks -1
     order by x.tch desc ;