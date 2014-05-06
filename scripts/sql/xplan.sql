clear SCREEN
set verify off

SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('&&sql_id'));

SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR('&&sql_id'));

UNDEFINE sql_id