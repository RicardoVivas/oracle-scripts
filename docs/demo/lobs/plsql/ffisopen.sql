/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/ffisopen.sql */

/* Checking if the BFILE is OPEN with FILEISOPEN. 
   Procedure seeIfOpenBFILE_procOne is not part of DBMS_LOB package: */

CREATE OR REPLACE PROCEDURE seeIfOpenBFILE_procOne IS
   file_loc      BFILE;
   RetVal       INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE FILEISOPEN EXAMPLE ------------');
   /* Select the LOB, initializing the BFILE locator: */
   SELECT ad_graphic INTO file_loc FROM Print_media
          WHERE product_ID = 3060 AND ad_id = 11001;
   RetVal := DBMS_LOB.FILEISOPEN(file_loc);
   IF (RetVal = 1)
      THEN
      DBMS_OUTPUT.PUT_LINE('File is open');
   ELSE
      DBMS_OUTPUT.PUT_LINE('File is not open');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Operation failed');
END;
/
SHOW ERRORS;

