---------------------- Baselines ----------------------

DBMS_WORKLOAD_REPOSITORY.create_baseline(
    start_snap_id => 2490,
    end_snap_id   => 2491,
    baseline_name => 'test1_bl',
    expiration    => 60);  -- Expiration in number of days for the baseline. If NULL, then expiration is infinite, meaning do not drop baseline ever. Defaults to NULL.

DBMS_WORKLOAD_REPOSITORY.create_baseline(
    start_time    => TO_DATE('09-JUL-2008 17:00', 'DD-MON-YYYY HH24:MI'),
    end_time      => TO_DATE('09-JUL-2008 18:00', 'DD-MON-YYYY HH24:MI'),
    baseline_name => 'test2_bl',
    expiration    => NULL);
    
SELECT * FROM DBA_HIST_BASELINE

--Information about a specific baseline can be displayed by
SELECT * FROM   TABLE(DBMS_WORKLOAD_REPOSITORY.select_baseline_details(6));
SELECT * FROM   TABLE(DBMS_WORKLOAD_REPOSITORY.select_baseline_metric('SYSTEM_MOVING_WINDOW'));

-- Drop & rename
DBMS_WORKLOAD_REPOSITORY.rename_baseline(
    old_baseline_name => 'test4_bl',
    new_baseline_name => 'test5_bl');

DBMS_WORKLOAD_REPOSITORY.drop_baseline(baseline_name => 'test1_bl');


---------------------- Snapshot ----------------------

dba_hist_snapshot

execute dbms_workload_repository.create_snapshot();
EXECUTE DBMS_WORKLOAD_REPOSITORY.DROP_SNAPSHOT_RANGE(102, 105);


---------------------- Report ----------------------

DBMS_WORKLOAD_REPOSITORY.ASH_REPORT_HTML(
   l_dbid          IN NUMBER,
   l_inst_num      IN NUMBER,
   l_btime         IN DATE,
   l_etime         IN DATE,
)

You can call the function directly but Oracle recommends you use the ashrpt.sql script which prompts users for the required information.

DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(
   l_dbid       IN    NUMBER,
   l_inst_num   IN    NUMBER,
   l_bid        IN    NUMBER,
   l_eid        IN    NUMBER,
   l_options    IN    NUMBER DEFAULT 0)
 RETURN awrrpt_text_type_table PIPELINED;

You can call the function directly but Oracle recommends you use the awrrpt.sql script which prompts users for the required information.
