-- See here http://orafaq.com/node/758
--v$open_cursor shows cached cursors, not currently open cursors, by session. 
--If you're wondering how many cursors a session has open, don't look in v$open_cursor. 
--It shows the cursors in the session cursor cache for each session, not cursors that are actually open.

--To monitor open cursors, query v$sesstat where name='opened cursors current'. This will give the number of currently opened cursors, by session:

--total cursors open, by session
select a.value, s.username, s.sid, s.serial#
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic#  and s.sid=a.sid
and b.name = 'opened cursors current'
order by 1;

--If you're running several N-tiered applications with multiple webservers, you may find it useful to monitor open cursors by username and machine:

--total cursors open, by username & machine
select sum(a.value) total_cur, avg(a.value) avg_cur, max(a.value) max_cur, 
s.username, s.machine
from v$sesstat a, v$statname b, v$session s 
where a.statistic# = b.statistic#  and s.sid=a.sid
and b.name = 'opened cursors current' 
group by s.username, s.machine
order by 1 desc;
