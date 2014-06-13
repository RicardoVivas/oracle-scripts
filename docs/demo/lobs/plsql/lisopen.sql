/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lisopen.sql */

/* Procedure lobIsOpen_proc is not part of the DBMS_LOB package: */

/* seeing if lob is open */

CREATE OR REPLACE PROCEDURE lobIsOpen_proc (Lob_loc IN OUT BLOB) IS
   /* Note: Lob_loc can be a persistent or a temporary LOB */
   Retval      INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB ISOPEN EXAMPLE ------------');
   /* See if the LOB is open: */
   Retval := DBMS_LOB.ISOPEN(Lob_loc);
   /* The value of Retval will be 1 meaning that the LOB is open. */

   if Retval = 1 THEN
     DBMS_OUTPUT.PUT_LINE('Input locator is open');
   else
     DBMS_OUTPUT.PUT_LINE('Input locator is not open');
   end if;
END;
/
SHOW ERRORS;
