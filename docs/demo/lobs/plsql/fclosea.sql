/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fclosea.sql */

/* Closing all open BFILEs.  
   Procedure closeAllOpenFilesBFILE_proc is not part of DBMS_LOB package: */
   
CREATE OR REPLACE PROCEDURE closeAllOpenBFILEs_proc IS
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE CLOSEALL EXAMPLE ------------');
   /* Close all open BFILEs: */
   DBMS_LOB.FILECLOSEALL;
END;
/
SHOW ERRORS;

