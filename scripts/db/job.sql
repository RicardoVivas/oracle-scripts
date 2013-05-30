SET NULL **
select owner, job_name, substr(schedule_name, 1,25),  substr(repeat_interval, 1, 20),  last_start_date, last_run_duration, next_run_date, run_count, enabled, 
state, start_date, restartable, job_type, schedule_type,  substr(job_action,1,50),  stop_on_window_close 
from dba_scheduler_jobs 
order by last_start_date desc nulls last

select * from dba_scheduler_job_run_details order by actual_start_date desc;

select * from dba_scheduler_windows order by window_name;

select * from dba_scheduler_window_details order by actual_start_date desc;

select * from dba_scheduler_window_log order by log_date desc;




BEGIN
DBMS_SCHEDULER.DISABLE(name=>'"SYS"."WEEKNIGHT_WINDOW"',force=>TRUE);
END;

BEGIN
DBMS_SCHEDULER.SET_ATTRIBUTE(name=>'"SYS"."WEEKNIGHT_WINDOW"',attribute=>'START_DATE',value=>to_timestamp_tz('2011-04-07 +1:00', 'YYYY-MM-DD TZH:TZM'));
END;

BEGIN
DBMS_SCHEDULER.ENABLE(name=>'"SYS"."WEEKNIGHT_WINDOW"');
END;


DBMS_SCHEDULER.DROP_JOB(JOB_NAME => 'my_jobname');


-- 11g ------


-- displays per-window history of job execution counts for each automated maintenance task. 
-- This information is viewable in the Job History page of Enterprise Manager.
select * from dba_autotask_client_history order by window_start_time desc

-- displays the history of automated maintenance task job runs.
-- Jobs are added to this view after they finish executing.
select * from dba_autotask_job_history order by job_start_time desc

-- displays information about current and past automated maintenance tasks.
select * from dba_autotask_task

-- displays statistical data for each automated maintenance task over 7-day and 30-day periods.-----
select * from dba_autotask_client


dbms_auto_task_admin
dbms_auto_task_immediate


To disable individual:

BEGIN
dbms_auto_task_admin.disable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'THURSDAY_WINDOW');
dbms_auto_task_admin.disable(client_name => 'sql tuning advisor', operation => NULL, window_name => 'FRIDAY_WINDOW');
END;

To disable in all windows:

BEGIN
dbms_auto_task_admin.disable(client_name => 'sql tuning advisor', operation => NULL, window_name => NULL);
dbms_auto_task_admin.disable(client_name => 'auto space advisor', operation => NULL, window_name => NULL);
dbms_auto_task_admin.disable(client_name => 'auto optimizer stats collection', operation => NULL, window_name => NULL);
END;

BEGIN
dbms_auto_task_admin.disable();
END;