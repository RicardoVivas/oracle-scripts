You must enable supplemental logging prior to generating log files that will be analyzed by LogMiner.

alter database add supplemental log data;
select  supplemental_log_data_min from v$database;


EXECUTE DBMS_LOGMNR.ADD_LOGFILE( LOGFILENAME => '/package/oracle/oradata/jocasta/jocasta1_41279_671731933.dbf', OPTIONS => DBMS_LOGMNR.NEW);
EXECUTE DBMS_LOGMNR.ADD_LOGFILE( LOGFILENAME => '/package/oracle/oradata/jocasta/jocasta1_41280_671731933.dbf', OPTIONS => DBMS_LOGMNR.ADDFILE);
EXECUTE DBMS_LOGMNR.START_LOGMNR( OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG);

SELECT  SQL_REDO, TIMESTAMP, SESSION_INFO FROM V$LOGMNR_CONTENTS

EXECUTE DBMS_LOGMNR.END_LOGMNR();



More options can be found in Oracle library book "Database Utilities" Charpter 17 "Using LogMiner to Analyze Redo Log Files"
