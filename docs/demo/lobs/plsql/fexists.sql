/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fexists.sql */

/* Checking if a BFILE exists */
/* Procedure seeIfExistsBFILE_proc is not part of DBMS_LOB package:  */

CREATE OR REPLACE PROCEDURE seeIfExistsBFILE_proc IS
   file_loc      BFILE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE FILEEXISTS EXAMPLE ------------');
   /* Select the LOB: */
   SELECT ad_graphic INTO File_loc FROM print_media 
      WHERE product_id = 3060 AND ad_id = 11001;

   /* See If the BFILE exists: */
   IF (DBMS_LOB.FILEEXISTS(file_loc) != 0)
   THEN
      DBMS_OUTPUT.PUT_LINE('Processing given that the BFILE exists');
   ELSE
      DBMS_OUTPUT.PUT_LINE('Processing given that the BFILE does not exist');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Operation failed');
END;
/
SHOW ERRORS;

