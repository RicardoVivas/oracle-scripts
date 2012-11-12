
select *  from DBA_SCHEDULER_JOBS
Oracle automatically schedules the GATHER_STATS_JOB job to run when the maintenance window opens
exec dbms_scheduler.enable('GATHER_STATS_JOB');



select * from DBA_HIST_SNAPSHOT ORDER BY SNAP_ID DESC

EXEC  dbms_workload_repository.modify_snapshot_settings(retention=>10080,interval=>60);
SELECT * FROM dba_hist_wr_control;


EXEC dbms_workload_repository.create_snapshot;

EXEC dbms_workload_repository.drop_snapshot_range (low_snap_id=>1107, high_snap_id=>1108);