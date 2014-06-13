/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fread.sql */

/* Reading data from a BFILE. */
/* Procedure readBFILE_proc is not part of DBMS_LOB package: */

CREATE OR REPLACE PROCEDURE readBFILE_proc IS
   file_loc      BFILE;
   Amount        INTEGER := 32767;
   Position      INTEGER := 1;
   Buffer        RAW(32767);
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE READ EXAMPLE ------------');
   /* Select the LOB: */ 
   SELECT ad_graphic INTO File_loc FROM print_media 
      WHERE product_id = 3060 AND ad_id = 11001;
   /* Open the BFILE: */  
   DBMS_LOB.OPEN(File_loc, DBMS_LOB.LOB_READONLY);
   /* Read data: */  
   DBMS_LOB.READ(File_loc, Amount, Position, Buffer);
   /* Close the BFILE: */  
   DBMS_LOB.CLOSE(File_loc);
END;
/
show errors;
