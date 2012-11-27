# check long running transaction

SELECT s.sid, s.machine, s.username, t.start_date , s.sql_id   FROM v$transaction t, v$session s   WHERE t.ses_addr = s.saddr;