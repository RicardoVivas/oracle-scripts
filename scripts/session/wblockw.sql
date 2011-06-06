Locking Issues:

check dba_waiters and dba_blockers to find out who is holding the lock and who is waiting.
(must run catblock.sql to create these two views)
Use utllockt.sql (must run after the catblock) to print the watt-for in a hierarchy.



Find out Who Locks, Which is Locked and Who is waiting

1) Who locks:

select sid from v$lock where block=1;  the session definitely block someone
v$lock.kaddr=v$session.lockwait



-- To find out whick SQL, check showsql.sql
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
