set echo off
set feedback off
set pagesize 0
set verify off
PROMPT Enter the name of the application owner:
ACCEPT app_owner
PROMPT Enter the name of the new tablespace for the application table:
ACCEPT new_tab_tablespace
PROMPT Enter the name of the new tablespace for the aplicastion index:
ACCEPT new_idx_tablespace

spool /tmp/MoveTablesIndexes.sql

-- move the tables to the news tablespace
SELECT 'ALTER TABLE '|| owner ||'.' ||table_name || CHR(10)||' MOVE TABLESPACE &new_tab_tablespace;' from dba_tables where owner=UPPER('&app_owner');

-- rebuld all indexes on the moved tables, even those not owned by the specified user 
-- because moving the tables will set their status to UNUSABLE (unless they are IOT tables)

SELECT 'ALTER INDEX ' || I.owner || '.' || I.index_name || CHR(10) || ' REBUILD TABLESPACE ' || I.tablespace_name || ';'
from DBA_INDEXES I, DBA_TABLES T WHERE I.table_name = T.table_name AND I.owner=T.owner AND T.owner = UPPER('&&app_owner');

-- rebuild any other indexes owned by this user taht may not be on the above tables

SELECT 'ALTER  INDEX ' || owner || '.' || index_name || CHR(10)|| ' REBUILD TABLESPACE &new_idx_tablespace;' from dba_indexes WHERE owner = UPPER('&&app_owner');



spool off
set echo on
set feedback on
set pagesize 60
spool /tmp/MoveTablesIndexes.log
#@/tmp/MoveTablesIndexes.sql
spool off

