1. PID from top helps identify top process and map that to Oracle Process

select s.username, s.sid, s.serial# ,p.spid from V$SESSION s, V$PROCESS p where s.PADDR = p.ADDR and p.spid='2597';

2. Enable trace

-- run as sys. To disable, use FALSE
exec dbms_system.set_sql_trace_in_session(sid,serial#,TRUE)

-- to find out what sql is the user executing
tkprof <sid>_ora_<spid>.trc /tmp/output.txt sys=no record=/tmp/a.sql

3. Find out what user is doing and what resoruce it is using

select a.sid,a.username,s.sql_text from v$session a,v$sqltext s 
  where a.sql_address=s.address and a.sql_hash_value=s.hash_value order by a.username,a.sid,s.piece
select a.username,a.sid,b.block_gets,b.consistent_gets,b.physical_reads,b.block_changes,b.consistent_changes 
  from v$session a,v$sess_io b where a.sid=b.sid order by a.username

--Find out which objects a user is accessing

select a.sid,a.username,b.owner,b.object,b.type from v$session a, v$access b where a.sid=b.sid


5. SQL Tune

1) . To find out long-running sql statements

select username,sql_text,sofar,totalwork,units from v$sql, v$session_longops 
 where sql_address=address and sql_hash_value=hash_value order by address,hash_value,child_number

2)  Identify statements get the most buffer per execution (CPU)

select b.username, a.buffer_gets, a.executions,a.buffer_gets/decode(a.executions,0,1,a.executions) ratio1,
  a.sql_text, a.last_load_time 
  from v$sql a, dba_users b 
  where a.parsing_user_id=b.user_id and a.buffer_gets/decode(a.executions,0,1,a.executions) > 150 
  order by ratio1 desc

select sql_text,  executions, round(buffer_gets / decode(executions,0,1,executions),1) buffer_exec_ratio 
  from v$sql where  executions > 0 order by bgs_exec_ratio desc

3)  Identify statements get the most disk reads per execution (IO)

select sql_text,  executions, round(disk_reads/decode(executions,0,1,executions),1) rds_exec_ratio 
  from v$sql 
  where  executions > 0 order by rds_exec_ratio desc

select b.username, a.disk_reads, a.executions, a.disk_reads/decode (a.executions,0,1,a.executions) rds_exec_ratio,
     a.sql_text 
     from v$sqlarea a, dba_users b 
     where a.parsing_user_id=b.user_id and a.disk_reads > 1000 order by a.disk_reads desc

4)  Check how long the user connection has been idle

select sid,username,status, to_char(logon_time,'dd-mm-yy hh:mi:ss') "LOGON", 
   floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE",
   program 
   from v$session 
   where type='USER' order by last_call_et DESC

5)  check how long the user connection and find its PID and use kill -9 to kill it
select s.sid,p.spid, s.status, s.username,logon_time,last_call_et/3600/24 "IDLE" 
  from v$session s, v$process p where s.username='WSOS' and s.PADDR = p.ADDR 
  order by s.last_call_et desc

6 Waiting Events

1). which event is waiting
   select p1,p2 from v$session_wait

2). To find out which object is waiting for. File# and block# are from v$session_wait (p1,p2)
   select owner,segment_name from dba_extents where FILE_ID= file# AND  block# between block_id 
   AND (block_id + blocks -1 )

3) . find out who is access this object
   select sid from v$access where object=sgement_name

4) . find out what is he doing

    select a.sid,a.username,s.sql_text from v$session a,v$sqltext s 
      where a.sid = sid# and a.sql_address=s.address and a.sql_hash_value=s.hash_value 
      order by a.username,a.sid,s.piece

     or

    select s.sql_address,s.sql_hash_value from v$session s, v$session_wait w 
      where w.event like 'db file%read' and w.sid=s.sid;

7 Gather Statistics

  execute dbms_stats.gather_schema_stats(ownname=>'&schema', 
    estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, 
    method_opt=> 'for all columns size AUTO',cascade => TRUE);
    
8. Enable Autotrace

1) Require plan_table and plustrace role
2) rdbms/admin/utlxplan.sql to create plan_table
3)  create plustrace role using $ORACLE_HOME/sqlplus/admin/plustrce.sql
4) set autotrace [off | on | traceoff ] [ explain | statistics]

9. Explan Plan

1) Expain Plan [set statement_id='<name> ' into my_plan_table ]for  select ..
2) To display:  

      select * from table(dbms_xplan.display);

--------------------------------- Reference ---------------------------------------


*  Dynamic view v$session_wait

This view  is very important.For waiting event display, go to
http://download-west.oracle.com/docs/cd/B10501_01/server.920/a96536/apa.htm#968373

*  Top 5 Event

does not coresponding OEM. I have a program to simulate OEM -----
select event,sum(decode(wait_Time,0,0,1)) "Prev", sum(decode(wait_Time,0,1,0)) "Curr",count(*) "Tot" 
from v$session_Wait group by event order by 4;

* v$sessinon and v$process  explain

v$session.saddr: session adress
v$session.paddr(Y):Address of the process that owns this session
v$session.process: Operating system client process ID 
   (This is client process, which will cause a server process to be created.
   
The server proces is v$process.spid. 
it display v$process.spid directly instead of client process id)
v$process.addr(Y):Address of process state object
v$process.pid: Oracle process identifier 
v$process.spid(Y):Operating system process identifier

