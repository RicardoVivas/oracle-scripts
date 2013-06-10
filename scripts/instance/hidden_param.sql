# List all undocumented parameters; Run as sysdba

COLUMN parameter           FORMAT a37
COLUMN description         FORMAT a30 WORD_WRAPPED
COLUMN "Session Value"     FORMAT a10
COLUMN "Instance Value"    FORMAT a10
SET LINES 100
SET PAGES 0
SPOOL undoc.lis

SELECT  
   a.ksppinm  "Parameter",  
   a.ksppdesc "Description", 
   b.ksppstvl "Session Value",
   c.ksppstvl "Instance Value"
FROM 
   x$ksppi a, 
   x$ksppcv b, 
   x$ksppsv c
WHERE 
   a.indx = b.indx 
   AND 
   a.indx = c.indx
   AND 
   a.ksppinm LIKE '/_%' escape '/'
ORDER BY
  A.KSPPINM
/