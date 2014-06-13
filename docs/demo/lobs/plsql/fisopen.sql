/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fisopen.sql */

/* Checking if the BFILE is open with ISOPEN */
/* Procedure seeIfOpenBFILE_procTwo is not part of DBMS_LOB package: */

CREATE OR REPLACE PROCEDURE seeIfOpenBFILE_procTwo IS
   file_loc     BFILE;
   RetVal       INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE ISOPEN EXAMPLE ------------');
   /* Select the LOB, initializing the BFILE locator: */
   SELECT ad_graphic INTO file_loc FROM Print_media
      WHERE product_ID = 3060 AND ad_id = 11001;
   RetVal := DBMS_LOB.ISOPEN(file_loc);
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

