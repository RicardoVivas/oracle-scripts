/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lread.sql */

/* Procedure readLOB_proc is not part of the DBMS_LOB package: */

/* reading data from lob */

CREATE OR REPLACE PROCEDURE readLOB_proc (Lob_loc IN OUT BLOB) IS
    /* Note: Lob_loc can be a persistent or a temporary LOB */
    Buffer            RAW(32767);
    Amount            BINARY_INTEGER := 32767;
    Position          INTEGER := 2;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB READ EXAMPLE ------------');
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READONLY);
   /* Read data from the LOB: */
   DBMS_LOB.READ (Lob_loc, Amount, Position, Buffer);
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (Lob_loc);

   DBMS_OUTPUT.PUT_LINE(RAWTOHEX(substr(Buffer, 1, 200)));
END;
/

SHOW ERRORS;

