rem - see  http://blogs.warwick.ac.uk/java/entry/direct_path_readuser/ for more information

select a.NAME,  b.SID,  b.VALUE, c.username, c.program,  round((sysdate - c.LOGON_TIME) * 24) hours_connected 
from v$statname a, v$sesstat b, v$session c 
where b.SID = c.SID and a.STATISTIC# = b.STATISTIC# and b.VALUE > 0  and a.NAME = 'physical reads direct' 
order by b.VALUE desc
