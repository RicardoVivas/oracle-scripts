select sql_id, decode(wait_class, null,'ON CPU', wait_class) wait_class, round(100*RATIO_TO_REPORT(COUNT(*)) OVER (),2) || '%' AS PCT_TOTAL, count(*)  from v$active_session_history 
where sample_time > sysdate - 5/24/60 group by sql_id, wait_class  
having count(*) > 1
order by count(*) ;