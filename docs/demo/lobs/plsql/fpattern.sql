/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fcompare.sql */

/* Comparing all or parts of two BFILES.  */
/* Procedure instringBFILE_proc is not part of DBMS_LOB package: */
CREATE OR REPLACE PROCEDURE instringBFILE_proc IS
   file_loc      BFILE;
   Pattern        RAW(32767);
   Position       INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE INSTR EXAMPLE ------------');
   /* Select the LOB: */
   SELECT PMtab.ad_graphic INTO file_loc FROM Print_media PMtab
          WHERE PMtab.product_id = 3060 AND PMtab.ad_id = 11001;

   /* Open the BFILE: */
   DBMS_LOB.OPEN(file_loc, DBMS_LOB.LOB_READONLY);
   /*  Initialize the pattern for which to search, find the 2nd occurrence of
       the pattern starting from the beginning of the BFILE: */
   Position := DBMS_LOB.INSTR(file_loc, Pattern, 1, 2);
   /* Close the BFILE: */
   DBMS_LOB.CLOSE(file_loc);
END;
/
SHOW ERRORS;

