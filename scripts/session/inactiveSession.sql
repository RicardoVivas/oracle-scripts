select username,machine,program   from v$session  where last_call_et > (60*&&minute_inactive) and username is not null order by last_call_et;



select username,logon_time,last_call_et,to_char(sysdate-(last_call_et/(60*60*24)),'hh24:mi:ss') last_work_time
from v$session where username is not null
