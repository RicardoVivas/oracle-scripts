/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lsubstr.sql */

/* Procedure substringLOB_proc is not part of the DBMS_LOB package: */

/* reading portion of lob (substr) */

CREATE OR REPLACE PROCEDURE substringLOB_proc (Lob_loc IN OUT BLOB) IS
    /* Note: Lob_loca can be a persistent or a temporary LOB */
    Amount            BINARY_INTEGER := 32767;
    Position          INTEGER := 3;
    Buffer            RAW(32767);
BEGIN
    DBMS_OUTPUT.PUT_LINE('------------ LOB SUBSTR EXAMPLE ------------');
    /* Opening the LOB is optional: */
    DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READONLY);
    Buffer := DBMS_LOB.SUBSTR(Lob_loc, Amount, Position);
    /* Process the data */
    /* Closing the LOB is mandatory if you have opened it: */
    DBMS_LOB.CLOSE (Lob_loc);
    DBMS_OUTPUT.PUT_LINE(rawtohex(substr(buffer,1,200)));
END;
/

SHOW ERRORS;

/* For persistent LOBs, DBMS_LOB.SUBSTR can be used in a SQL statement too.
   In the following SQL statement, 200 is the amount to read 
   and 1 is the starting offset from which to read: */
SELECT DBMS_LOB.SUBSTR(ad_sourcetext, 200, 1) FROM print_media 
WHERE product_id = 2268;

