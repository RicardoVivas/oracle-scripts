/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fcopyloc.sql */

/* Copying a LOB locator for a BFILE. */
/* Procedure BFILEAssign_proc is not part of DBMS_LOB package:   */

CREATE OR REPLACE PROCEDURE BFILEAssign_proc IS
   file_loc1    BFILE := BFILENAME('MEDIA_DIR', 'keyboard_logo.jpg');
   file_loc2    BFILE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE ASSIGN EXAMPLE ------------');
   /*
   SELECT Photo INTO file_loc1 FROM print_media 
      WHERE Product_ID = 3060 AND ad_id = 11001 
      	FOR UPDATE; */
   /* Assign file_loc1 to file_loc2 so that they both */ 
   /* refer to the same operating system file:        */
   file_loc2 := file_loc1;
   /* Now you can read the bfile from either file_loc1 or file_loc2. */
END;
/
SHOW ERRORS;

