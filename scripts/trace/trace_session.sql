-- run as sys 
exec dbms_system.set_sql_trace_in_session(&sid,&serial_number,TRUE);

exec dbms_system.set_sql_trace_in_session(&sid,&serial_number,FALSE);


tkprof <sid>_ora_<spid>.trc /tmp/output.txt sys=no explain=name/pass record=/tmp/a.sql

