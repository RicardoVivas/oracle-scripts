/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/llength.sql */

/* Procedure getLengthLOB_proc is not part of the DBMS_LOB package: */

/* getting the length of a lob */

CREATE OR REPLACE PROCEDURE getLengthLOB_proc (Lob_loc IN OUT BLOB) IS
   /* Note: Lob_loc can be a persistent or temporary LOB */
   Length      INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB GETLENGTH EXAMPLE ------------');
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READONLY);
   /* Get the length of the LOB: */
   length := DBMS_LOB.GETLENGTH(Lob_loc);
   IF length IS NULL THEN
       DBMS_OUTPUT.PUT_LINE('LOB is null.');
   ELSE
       DBMS_OUTPUT.PUT_LINE('The length is '|| length);
   END IF;
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (Lob_loc);
END;
/
SHOW ERRORS;
