
-- For history info. Note its column is different to v$session-------------------------------------

select session_id, blocking_session, event, sample_time from  v$active_session_history 
where blocking_session is not null and sample_time > sysdate - 1/48 order by sample_time desc