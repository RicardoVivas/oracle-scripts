
The following is quite useful is you do not know the password of sysman

$ sqlplus SYS/sys_password AS SYSDBA

After you connect as the SYS user, alter the session to run as SYSMAN:
SQL> ALTER SESSION SET current_schema = SYSMAN;



logfile=pump-$ORACLE_SID-$now
dumpfile=pump-$ORACLE_SID-$now

$ORACLE_HOME/bin/expdp \"/ as sysdba\" directory=expdir schema=INTUIT include=INTUIT.MEN_GSLN        logfile=$logfile-1.log dumpfile=$dumpfile-1.dmp job_name=pump_$now_gsln 
$ORACLE_HOME/bin/expdp \"/ as sysdba\" directory=expdir schema=INTUIT UWTABS exclude=INTUIT.MEN_GSLN logfile=$logfile-2.log dumpfile=$dumpfile-2.dmp job_name=pump_$now_rest 

dumpJobStatus=`/usr/bin/tail -1 /server-backup/oradb/orabackup/$ORACLE_SID/export/$logfile-1.log`
dumpJobStatus2=`/usr/bin/tail -1 /server-backup/oradb/orabackup/$ORACLE_SID/export/$logfile-2.log`

$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF
delete from ops\$oracle.datapump_jobs where end_time < sysdate - 30;
insert into ops\$oracle.datapump_jobs(jobStatus, end_time) values ('$dumpJobStatus', sysdate);
insert into ops\$oracle.datapump_jobs(jobStatus, end_time) values ('$dumpJobStatus2', sysdate);
commit;
EOF
