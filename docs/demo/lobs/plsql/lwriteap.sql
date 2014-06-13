/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lwriteap.sql */

/* Procedure lobWriteAppend_proc is not part of the DBMS_LOB package: */

/* writing to the end of lob (write append) */

CREATE OR REPLACE PROCEDURE lobWriteAppend_proc (Lob_loc IN OUT BLOB) IS
   /* Note: Lob_loc can be a persistent or temporary LOB */
   Buffer     RAW(32767);
   Amount     Binary_integer := 4;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB WRITEAPPEND EXAMPLE ------------');
   /* Fill the buffer with data... */
   Buffer := hextoraw('ab2daa44');
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READWRITE);
   /* Append the data from the buffer to the end of the LOB: */
   DBMS_LOB.WRITEAPPEND(Lob_loc, Amount, Buffer);
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE(Lob_loc);
END;
/
SHOW ERRORS;

