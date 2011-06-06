set echo off
set feedback off
set pagesize 0
set verify off
spool kill_inactive_session.sh
select 'kill -9 ' ||  p.spid   from v$session s, v$process p  where p.addr = s.paddr and s.username='&&username' and s.last_call_et > (60*&&minute_inactive) order by s.last_call_et desc;
spool off
set echo on
set feedback on
set pagesize 60

