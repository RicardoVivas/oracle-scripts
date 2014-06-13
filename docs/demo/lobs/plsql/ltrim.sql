/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/ltrim.sql */

/* Procedure trimLOB_proc is not part of the DBMS_LOB package: */

/* trimming lob data */

CREATE OR REPLACE PROCEDURE trimLOB_proc (Lob_loc IN OUT BLOB) IS
    /* Note: Lob_loc can be a persistent or temporary LOB */
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB TRIM EXAMPLE ------------');
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READWRITE);
   /* Trim the LOB data: */
   DBMS_LOB.TRIM(Lob_loc,3);
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (Lob_loc);
   DBMS_OUTPUT.PUT_LINE('Trim succeeded');
/* Exception handling: */
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Trim failed');
END;
/
SHOW ERRORS;

