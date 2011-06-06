
mkdir /package/oracle/orabackup/db_replay_capture
CREATE OR REPLACE DIRECTORY DB_REPLAY_CAPTURE_DIR AS '/package/oracle/orabackup/db_replay_capture'

-- With filter 
exec DBMS_WORKLOAD_CAPTURE.ADD_FILTER (fname => 'capture_filter', fattribute => 'USER', fvalue => 'HSUN');
exec DBMS_WORKLOAD_CAPTURE.start_capture (name  => 'test_capture_2',   dir => 'DB_REPLAY_CAPTURE_DIR', duration => NULL, default_action => 'EXCLUDE');

-- Without filter
exec DBMS_WORKLOAD_CAPTURE.start_capture (name  => 'test_capture_2',   dir => 'DB_REPLAY_CAPTURE_DIR', duration => NULL);

SELECT * FROM DBA_WORKLOAD_CAPTURES;

exec DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE;


On test server
mkdir /package/oracle/orabackup/db_replay_capture
Copy the files to test server

CREATE OR REPLACE DIRECTORY DB_REPLAY_CAPTURE_DIR AS '/package/oracle/orabackup/db_replay_capture'

BEGIN
  DBMS_WORKLOAD_REPLAY.process_capture('DB_REPLAY_CAPTURE_DIR');
  DBMS_WORKLOAD_REPLAY.initialize_replay (replay_name => 'test_capture_2', replay_dir  => 'DB_REPLAY_CAPTURE_DIR');
  DBMS_WORKLOAD_REPLAY.prepare_replay (synchronization => TRUE);
END;

-- The calibration step tells us the number of replay clients and hosts necessary to faithfully replay the workload.
wrc mode=calibrate replaydir=/package/oracle/orabackup/db_replay_capture

-- 
wrc system/password@test mode=replay replaydir=/package/oracle/orabackup/db_replay_capture

exec DBMS_WORKLOAD_REPLAY.start_replay;

If you need to stop the replay before it is complete, call the CANCEL_REPLAY procedure.

SELECT *  FROM dba_workload_replays;


SET LIN 400
SET SERVEROUTPUT ON
DECLARE
  l_report  CLOB;
BEGIN
  l_report := DBMS_WORKLOAD_REPLAY.report(replay_id => 2,  format => 'TEXT');  -- OR format => 'HTML'
  dbms_output.put_line(l_report);
END;
