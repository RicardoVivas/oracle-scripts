SELECT v.value as numopencursors ,s.machine ,s.osuser,s.username, s.program  FROM V$SESSTAT v, V$SESSION s WHERE v.statistic# = 3 and v.sid = s.sid  order by 1

select * from v$open_cursor order by user_name