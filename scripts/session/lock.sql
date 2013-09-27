set echo on 
select b.spid, a.sid, a.serial#, a.username,  a.event, a.program from v$session a, v$process b where a.paddr = b.addr and a.sid in (select distinct blocking_session from v$session  where blocking_session is not null);

--To kill session, run : alter system kill session 'sid, serial#' immediate

select
(select username from v$session where sid=a.sid) blocker,
a.sid,
' is blocking ',
(select username from v$session where sid=b.sid) blockee,
b.sid
from v$lock a, v$lock b
where a.block = 1
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2;
