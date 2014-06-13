/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/listemp.sql */

/* Procedure isTempLob_proc is not part of the DBMS_LOB package: */

/* seeing if lob is temporary. */

CREATE or REPLACE PROCEDURE isTempLob_proc(Lob_loc IN OUT BLOB) IS
   /* Note: Lob_loc can be persistent or temporary LOB */
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB ISTEMPORARY EXAMPLE ------------');
   /* Check to make sure that the locator is pointing to a temporary LOB */
    IF DBMS_LOB.ISTEMPORARY(Lob_loc) = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Input locator is a temporary LOB locator');
    ELSE
        /* Print an error: */
        DBMS_OUTPUT.PUT_LINE('Input locator is not a temporary LOB locator');
    END IF;
END;
/
SHOW ERRORS;

