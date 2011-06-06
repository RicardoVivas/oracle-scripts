rem -----------------------------------------------------------------------
rem   Shows the foreign keys without appropriate index
rem -----------------------------------------------------------------------
rem
SET echo off
SET verify off
SET pagesize 100
--
COLUMN OWNER noprint new_value own
COLUMN TABLE_NAME format a24 wrap heading "Table Name"
COLUMN CONSTRAINT_NAME format a24 wrap heading "Constraint Name"
COLUMN CONSTRAINT_TYPE format a3 heading "Typ"
COLUMN COLUMN_NAME format a24 wrap heading "1. Column"
BREAK ON OWNER skip page
--
SET TERMOUT ON
TTITLE  CENTER 'Unindexed Foreign Keys owned by Owner: ' own SKIP 2
PROMPT
PROMPT Please enter Owner Name and Table Name. Wildcards allowed (DEFAULT: %)
PROMPT
PROMPT eg.:  SCOTT, S% OR %
PROMPT
--
ACCEPT vOwner prompt "Owner  <%>: " DEFAULT %
--
SELECT OWNER, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME  FROM DBA_CONS_COLUMNS c
  WHERE position=1 AND
   (OWNER, TABLE_NAME, COLUMN_NAME) IN
   (SELECT c.OWNER, c.TABLE_NAME,cc.COLUMN_NAME
      FROM DBA_CONSTRAINTS  c, DBA_CONS_COLUMNS cc
     WHERE c.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
       AND c.TABLE_NAME      = cc.TABLE_NAME
       AND c.OWNER           = cc.OWNER
       AND c.CONSTRAINT_TYPE = 'R'
       AND cc.POSITION       = 1
       AND c.OWNER           LIKE UPPER('&vOwner')
     MINUS
    SELECT table_owner, table_name, column_name
      FROM DBA_IND_COLUMNS
     WHERE COLUMN_POSITION = 1
       AND TABLE_OWNER LIKE UPPER('&vOwner')
  )
  ORDER BY OWNER, TABLE_NAME, CONSTRAINT_NAME;
--
ttitle off
SET pause off
COLUMN TABLE_NAME clear
COLUMN CONSTRAINT_NAME clear
COLUMN CONSTRAINT_TYPE clear
COLUMN COLUMN_NAME clear
clear breaks


