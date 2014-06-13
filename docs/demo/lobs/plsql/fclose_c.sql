/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fclose_c.sql */

/* Closing a BFILE with CLOSE. 
   Procedure closeBFILE_procTwo is not part of DBMS_LOB package: */
   
CREATE OR REPLACE PROCEDURE closeBFILE_procTwo IS
   file_loc      BFILE := BFILENAME('MEDIA_DIR', 'keyboard_logo.jpg');
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE CLOSE EXAMPLE ------------');
   DBMS_LOB.OPEN(file_loc, DBMS_LOB.LOB_READONLY);
   /* ...Do some processing. */
   DBMS_LOB.CLOSE(file_loc);
END;
/
SHOW ERRORS;

