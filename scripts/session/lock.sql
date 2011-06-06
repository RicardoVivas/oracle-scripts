set echo on 
select b.spid, a.sid, a.serial#, a.username,  a.event, a.program from v$session a, v$process b where a.paddr = b.addr and a.sid in (select distinct blocking_session from v$session  where blocking_session is not null);

--To kill session, run : alter system kill session 'sid, serial#' immediate