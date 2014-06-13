/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/flength.sql */

/* Getting the length of a BFILE. */ 
/* Procedure getLengthBFILE_proc is not part of DBMS_LOB package: */

CREATE OR REPLACE PROCEDURE getLengthBFILE_proc IS
   file_loc      BFILE;
   Length       INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE LENGTH EXAMPLE ------------');
   /* Initialize the BFILE locator by selecting the LOB: */
   SELECT PMtab.ad_graphic INTO file_loc FROM Print_media PMtab
          WHERE PMtab.product_id = 3060 AND PMtab.ad_id = 11001;
   /* Open the BFILE: */
   DBMS_LOB.OPEN(file_loc, DBMS_LOB.LOB_READONLY);
   /* Get the length of the LOB: */
   Length := DBMS_LOB.GETLENGTH(file_loc);
   IF Length IS NULL THEN
       DBMS_OUTPUT.PUT_LINE('BFILE is null.');
   ELSE
       DBMS_OUTPUT.PUT_LINE('The length is ' || length);
   END IF;
   /* Close the BFILE: */
   DBMS_LOB.CLOSE(file_loc);
END;
/
SHOW ERRORS;

