/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lerase.sql */

/* Procedure eraseLOB_proc is not part of the DBMS_LOB package: */

/* erasing part of a lob */

CREATE OR REPLACE PROCEDURE eraseLOB_proc (Lob_loc IN OUT BLOB) IS
   /* Note: Lob_loc can be a persistent or temporary LOB */
   Amount         INTEGER := 3000;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB ERASE EXAMPLE ------------');
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READWRITE);
   /* Erase the data: */
   DBMS_LOB.ERASE(Lob_loc, Amount, 4);
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (Lob_loc);
   DBMS_OUTPUT.PUT_LINE('Erase succeeded');
/* Exception handling: */
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erase failed');
END;
/
SHOW ERRORS;

