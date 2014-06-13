/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lcopyloc.sql */

/* Procedure lobAssign_proc is not part of the DBMS_LOB package. */

/* copying a lob locator */

CREATE OR REPLACE PROCEDURE lobAssign_proc (Lob_loc1 IN OUT BLOB) IS 
   /* Note that Lob_loc1 can be a persistent or temporary LOB */
  Lob_loc2    BLOB; 
BEGIN 
   DBMS_OUTPUT.PUT_LINE('------------ LOB ASSIGN EXAMPLE ------------');
   /* Assign Lob_loc1 to Lob_loc2 thereby saving a copy of the value of the
    * lob at this point in time. */ 
  Lob_loc2 := Lob_loc1; 
  /* When you write some data to the lob through Lob_loc1, Lob_loc2 will not 
   * see the newly written data whereas Lob_loc1 will see the new data. */ 
END; 
/
SHOW ERRORS;

