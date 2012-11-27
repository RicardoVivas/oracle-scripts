select v.USERNAME, v.SQL_ID, v.BLOCKS, s.SQL_TEXT, j.*
from v$tempseg_usage v,v$sqlarea s,
(select * from v$session i where i.STATUS = 'ACTIVE') j
where v.SQL_ID = s.SQL_ID
and v.SESSION_ADDR = j.saddr
order by v.blocks desc;