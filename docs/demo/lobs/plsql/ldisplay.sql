/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/ldisplay.sql */

/* Procedure displayLOB_proc is not part of the DBMS_LOB package: */ 

/* displaying lob data */

CREATE OR REPLACE PROCEDURE displayLOB_proc (Lob_loc IN OUT BLOB) IS 
    /* Note: Lob_loc can be a persistent or temporary LOB */
Buffer   RAW(1024); 
Amount   BINARY_INTEGER := 1024; 
Position INTEGER := 1; 
BEGIN 
   DBMS_OUTPUT.PUT_LINE('------------ LOB DATA DISPLAY EXAMPLE ------------');
   /* Opening the LOB is optional: */ 
   DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READONLY); 
   LOOP 
      DBMS_LOB.READ (Lob_loc, Amount, Position, Buffer); 
      /* Display the buffer contents: */ 
      DBMS_OUTPUT.PUT_LINE(rawtohex(Buffer)); 
      Position := Position + Amount; 
   END LOOP; 
   /* Closing the LOB is mandatory if you have opened it: */ 
   DBMS_LOB.CLOSE (Lob_loc); 
   EXCEPTION 
      WHEN OTHERS THEN 
        DBMS_LOB.CLOSE (Lob_loc);
END; 
/

SHOW ERRORS;

