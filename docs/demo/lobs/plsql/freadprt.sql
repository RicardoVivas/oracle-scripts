/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/freadprt.sql */

/* Reading portion of a BFILE data using substr. */
/* Procedure substringBFILE_proc is not part of DBMS_LOB package:  */

CREATE OR REPLACE PROCEDURE substringBFILE_proc IS
   file_loc        BFILE;
   Position        INTEGER := 1;
   Buffer          RAW(32767);

BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB SUBSTR EXAMPLE ------------');
   /* Select the LOB: */  
   SELECT PMtab.ad_graphic INTO file_loc FROM Print_media PMtab
      WHERE PMtab.product_id = 3060 AND PMtab.ad_id = 11001;
   /* Open the BFILE: */  
   DBMS_LOB.OPEN(file_loc, DBMS_LOB.LOB_READONLY);
   Buffer := DBMS_LOB.SUBSTR(file_loc, 255, Position);
   /* Close the BFILE: */  
   DBMS_LOB.CLOSE(file_loc);
END;
/
show errors;
