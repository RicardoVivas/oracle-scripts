/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fupdate.sql */

/* Updating a BFILE by initializing a BFILE locator. */ 
/* Procedure updateUseBindVariable_proc is not part of DBMS_LOB package: */
   
CREATE OR REPLACE PROCEDURE updateBFILEColumn_proc IS
   File_loc  BFILE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE UPDATE EXAMPLE ------------');
   SELECT ad_graphic INTO File_loc
      FROM Print_media
         WHERE product_id = 3060 AND ad_id = 11001;

   UPDATE Print_media SET ad_graphic = File_loc 
         WHERE product_id = 3060 AND ad_id = 11001;

END;
/ 

