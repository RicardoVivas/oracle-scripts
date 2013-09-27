set linesize 150;
set head on;
col sid_serial form a13
col ora_user for a15;
col object_name for a35;
col object_type for a10;
col lock_mode for a15;
col last_ddl for a8;
col status for a10;
break on sid_serial;


SELECT l.session_id||','||v.serial# sid_serial,
       l.ORACLE_USERNAME ora_user,
       o.object_name, 
       o.object_type, 
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
       to_char(o.last_ddl_time,'dd.mm.yy') last_ddl
FROM dba_objects o, gv$locked_object l, v$session v
WHERE o.object_id = l.object_id
      and l.SESSION_ID=v.sid
order by 2,3;
