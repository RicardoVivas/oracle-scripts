CLEAR SCREEN

SELECT l.session_id||','||v.serial# sid_serial,
       l.ORACLE_USERNAME ora_user,
       o.object_type || ': ' || o.object_name object_name, 
       DECODE(l.locked_mode,
          0, 'None',
          1, 'Null',
          2, 'Row-S (SS)',
          3, 'Row-X (SX)',
          4, 'Share',
          5, 'S/Row-X (SSX)',
          6, 'Exclusive', 
          TO_CHAR(l.locked_mode)
       ) lock_mode,
       o.status, 
       to_char(o.last_ddl_time,'dd/mm/yy hh24:mi:ss') last_ddl
FROM dba_objects o, gv$locked_object l, v$session v
WHERE o.object_id = l.object_id
      and l.SESSION_ID=v.sid
order by 2,3;
