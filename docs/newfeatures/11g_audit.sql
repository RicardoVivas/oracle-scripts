 

-- Step 1 Initialize 

SQL> EXEC  DBMS_AUDIT_MGMT.INIT_CLEANUP(AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,  DEFAULT_CLEANUP_INTERVAL => 24 );

--- Step 2   Timestamp Management

SQL> EXEC  DBMS_AUDIT_MGMT.set_last_archive_timestamp(audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,  last_archive_time => SYSTIMESTAMP -7);

--- Step 3 Create job

SQL> BEGIN  
    DBMS_AUDIT_MGMT.create_purge_job(
    audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,    
    audit_trail_purge_interval => 1 /* hours */,  
    audit_trail_purge_name => 'PURGE_XML_AUDIT_TRAILS', 
    use_last_arch_timestamp  => TRUE);
    END;


--- Change interval --------------
EXEC  DBMS_AUDIT_MGMT.SET_PURGE_JOB_INTERVAL(audit_trail_purge_name => 'PURGE_XML_AUDIT_TRAILS',  audit_trail_interval_value => 48);


-- Disable and Enable job
SQL> EXEC DBMS_AUDIT_MGMT.set_purge_job_status( audit_trail_purge_name => 'PURGE_XML_AUDIT_TRAILS', audit_trail_status_value => DBMS_AUDIT_MGMT.PURGE_JOB_DISABLE);
SQL> EXEC DBMS_AUDIT_MGMT.set_purge_job_status( audit_trail_purge_name => 'PURGE_XML_AUDIT_TRAILS', audit_trail_status_value => DBMS_AUDIT_MGMT.PURGE_JOB_ENABLE);

--Drop the job
SQL> EXEC  DBMS_AUDIT_MGMT.drop_purge_job( audit_trail_purge_name => 'PURGE_XML_AUDIT_TRAILS');


---------------------------------------------------------------------------------------------------------------------------------------------------

DBA_AUDIT_MGMT_CLEAN_EVENTS: Displays the cleanup event history
DBA_AUDIT_MGMT_CLEANUP_JOBS: Displays the currently configured audit trail purge jobs
DBA_AUDIT_MGMT_CONFIG_PARAMS: Displays the currently configured audit trail properties
DBA_AUDIT_MGMT_LAST_ARCH_TS: Displays the last archive timestamps set for the audit trails; set from DBMS_AUDIT_MGMT.set_last_archive_timestamp



-- Manually purge------

EXEC  DBMS_AUDIT_MGMT.clean_audit_trail( audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,  use_last_arch_timestamp => FALSE);

Use "FALSE" for use_last_arch_timestamp will delete all; Use "TRUE" will delete ones before the time set in DBMS_AUDIT_MGMT.set_last_archive_timestamp

---  

Have to initialized for cleanup

SQL> EXEC DBMS_AUDIT_MGMT.INIT_CLEANUP(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, default_cleanup_interval => 12 /* hours */);
SQL> EXEC  DBMS_AUDIT_MGMT.clean_audit_trail( audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, use_last_arch_timestamp => FALSE);

//---- Can cancel the DBMS_AUDIT_MGMT.INIT_CLEANUP settings, that is, the default cleanup interval, by invoking the following ------

SQL> EXEC DBMS_AUDIT_MGMT.DEINIT_CLEANUP(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML)

SQL> EXEC DBMS_AUDIT_MGMT.DEINIT_CLEANUP(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD)

