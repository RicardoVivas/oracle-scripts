/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lcompare.sql */

/* Procedure compareTwoLOBs_proc is not part of the DBMS_LOB package: */

/* comparing all or part of lob */

CREATE OR REPLACE PROCEDURE compareTwoLOBs_proc
    (Lob_loc1 IN OUT BLOB, Lob_loc2 IN OUT BLOB) IS
    /* Note: Lob_loc1 and Lob_loc2 can be persistent or temporary LOBs */
    Amount              INTEGER := 32767;
    Retval              INTEGER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('------------ LOB COMPARE EXAMPLE ------------');
    /* Opening the LOB is optional: */
    DBMS_LOB.OPEN (Lob_loc1, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.OPEN (Lob_loc2, DBMS_LOB.LOB_READONLY);
    /* Compare the two LOBs: */
    retval := DBMS_LOB.COMPARE(Lob_loc1, Lob_loc2, Amount, 1, 1);
    IF retval = 0 THEN
       DBMS_OUTPUT.PUT_LINE('LOBs are equal');
    ELSE
       DBMS_OUTPUT.PUT_LINE('LOBs are not equal');
    END IF;
    /* Closing the LOB is mandatory if you have opened it: */
    DBMS_LOB.CLOSE (Lob_loc1);
    DBMS_LOB.CLOSE (Lob_loc2);
END;
/

SHOW ERRORS;

