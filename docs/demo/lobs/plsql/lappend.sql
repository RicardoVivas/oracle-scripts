/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lappend.sql */

/* Procedure appendLOB_proc is not part of the DBMS_LOB package: */

/* appending one lob to another */

CREATE OR REPLACE PROCEDURE appendLOB_proc
   (Dest_loc IN OUT BLOB, Src_loc IN OUT BLOB) IS
   /* Note: Dest_loc and Src_loc can be persistent or temporary LOBs */
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB APPEND EXAMPLE ------------');
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (Dest_loc, DBMS_LOB.LOB_READWRITE);
   DBMS_LOB.OPEN (Src_loc, DBMS_LOB.LOB_READONLY);
   DBMS_LOB.APPEND(Dest_loc, Src_loc);
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (Dest_loc);
   DBMS_LOB.CLOSE (Src_loc);
   DBMS_OUTPUT.PUT_LINE('Append succeeded');

EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Append failed');
      DBMS_LOB.CLOSE (Dest_loc);
      DBMS_LOB.CLOSE (Src_loc);
END;
/
SHOW ERRORS;

