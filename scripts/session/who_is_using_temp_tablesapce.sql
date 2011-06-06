SELECT distinct s.username, s.sid, s.serial#, s.osuser, u.tablespace, u.contents, u.segtype, u.extents, u.blocks
FROM v$session s, v$sort_usage u
WHERE s.saddr=u.session_addr
order by s.username, s.osuser;