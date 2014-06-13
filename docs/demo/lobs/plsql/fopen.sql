/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fopen.sql */

/* Opening a BFILE with OPEN.  */
/* Procedure openBFILE_procTwo is not part of DBMS_LOB package:  */
CREATE OR REPLACE PROCEDURE openBFILE_procTwo IS 
   file_loc      BFILE := BFILENAME('MEDIA_DIR', 'keyboard_logo.jpg');
BEGIN 
   DBMS_OUTPUT.PUT_LINE('------------ BFILE OPEN EXAMPLE ------------');
   /* Open the BFILE: */ 
   DBMS_LOB.OPEN (file_loc, DBMS_LOB.LOB_READONLY);
   /* ... Do some processing: */ 
   DBMS_LOB.CLOSE(file_loc);
END;
/
