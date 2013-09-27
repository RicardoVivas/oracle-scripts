CLEAR SCREEN

select round(count(*)/60/5,1) active_sessions from v$active_session_history where sample_time > sysdate - 5/24/60 ;

select sql_id, substr(decode(wait_class, null,'ON CPU', wait_class),1,15) wait_class,  
substr(round(100*RATIO_TO_REPORT(COUNT(*)) OVER (),2) || '%',1,10) AS PCT_TOTAL, count(*) 
from v$active_session_history 
where sample_time > sysdate - 5/24/60 
group by sql_id, wait_class  
having count(*) > 2
order by count(*) desc;

select substr(decode(wait_class, null,'ON CPU', wait_class),1,15)  wait_class, 
substr(round(100*RATIO_TO_REPORT(COUNT(*)) OVER (),2) || '%',1,10) AS PCT_TOTAL,  count(*)
from v$active_session_history where sample_time > sysdate - 5/24/60 
group by  wait_class
having count(*) > 2
order by count(*) desc;


select a.session_id, substr(b.name,1,20) username, substr(decode(a.wait_class, null,'ON CPU', a.wait_class),1,15) wait_class, 
substr(round(100*RATIO_TO_REPORT(COUNT(*)) OVER (),2) || '%',1,10) AS PCT_TOTAL, count(*)
from v$active_session_history a, SYS.USER$  b
where sample_time > sysdate - 5/24/60 and
a.user_id = b.user#
group by a.session_id, a.wait_class, b.name 
having count(*) > 2
order by count(*) desc;