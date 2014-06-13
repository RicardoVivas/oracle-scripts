/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fclose_f.sql */

/* Closing a BFILE with FILECLOSE. 
   Procedure closeBFILE_procOne is not part of DBMS_LOB package: */
   
CREATE OR REPLACE PROCEDURE closeBFILE_procOne IS
   file_loc      BFILE := BFILENAME('MEDIA_DIR', 'keyboard_logo.jpg');
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE FILECLOSE EXAMPLE ------------');
   DBMS_LOB.FILEOPEN(file_loc, DBMS_LOB.FILE_READONLY);
   /* ...Do some processing. */
   DBMS_LOB.FILECLOSE(file_loc);
END;
/
SHOW ERRORS;

