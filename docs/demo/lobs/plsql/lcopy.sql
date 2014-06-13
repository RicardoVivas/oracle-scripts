/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lcopy.sql */

/* Procedure copyLOB_proc is not part of the DBMS_LOB package: */

/* copying all or part of a lob to another lob */

CREATE OR REPLACE PROCEDURE copyLOB_proc
   (Dest_loc IN OUT BLOB, Src_loc IN OUT BLOB) IS
   /* Note: Dest_loc and Src_loc can be persistent or temporary LOBs */
   Amount       NUMBER := 1;
   Dest_pos     NUMBER := 3;
   Src_pos      NUMBER := 2;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB COPY EXAMPLE ------------');
   /* Opening the LOBs is optional: */
   DBMS_LOB.OPEN(Dest_loc, DBMS_LOB.LOB_READWRITE);
   DBMS_LOB.OPEN(Src_loc, DBMS_LOB.LOB_READONLY);
   /* Copies the LOB from the source position to the destination position: */
   DBMS_LOB.COPY(Dest_loc, Src_loc, Amount, Dest_pos, Src_pos);
   /* Closing LOBs is mandatory if you have opened them: */
   DBMS_LOB.CLOSE(Dest_loc);
   DBMS_LOB.CLOSE(Src_loc);
   DBMS_OUTPUT.PUT_LINE('Copy succeeded');
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Copy failed');
      DBMS_LOB.CLOSE(Dest_loc);
      DBMS_LOB.CLOSE(Src_loc);
END;
/
SHOW ERRORS;

