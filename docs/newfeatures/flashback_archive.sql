create tablespace  archives datafile '/package/oracle/oradata/perseus/archives01.dbf' size 500m autoextend on;
create flashback   archive default  sb2_archive tablespace archives   [ quota 500m ]  retention 3 month;


grant  flashback archive on sb2_archive to sb2test;
grant  flashback archive administer to sb2test;
//need to grant this to sysas as well
grant  flashback archive administer to  sysas;

alter table news_item     flashback archive;
alter table news_item no  flashback archive;

select * from dba_flashback_archive
select * from dba_flashback_archive_ts
select * from dba_flashback_archive_tables



select 'alter table ' || table_name || ' flashback archive; ' from tabS  where table_name NOT IN ('HITLOG', 'AUDIT_TRAIL') ORDER BY 1;





alter user sb2 quota unlimited on archives;  (do you have to??  No!)


create flashback archive default  sb2_archive tablespace archives  retention 3 month;
alter flashback archive sb2_archive modify tablespace archives  quota 500m; (do you have to??  No!)




select * from v$undostat;
select * from v$transaction;
select * from DBA_UNDO_EXTENTS;
SELECT * FROM v$rollname;
select owner, segment_name, tablespace_name, status from dba_rollback_segs