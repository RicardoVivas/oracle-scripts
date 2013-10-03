Locking Issues:

check dba_waiters and dba_blockers to find out who is holding the lock and who is waiting.
(must run catblock.sql to create these two views)
Use utllockt.sql (must run after the catblock.sql) to print the wait-for in a hierarchy.

Find out Who Locks, Which is Locked and Who is waiting

1) Who locks:

select sid from v$lock where block=1;  the session definitely block someone

v$lock.kaddr=v$session.lockwait



