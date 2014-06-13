/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fdisplay.sql */

/* Displaying BFILE data.  */
/* Procedure displayBFILE_proc is not part of DBMS_LOB package: */ 

CREATE OR REPLACE PROCEDURE displayBFILE_proc IS 
   file_loc BFILE := BFILENAME('MEDIA_DIR', 'monitor_3060.txt');
   Buffer   RAW(1024); 
   Amount   BINARY_INTEGER := 200; 
   Position INTEGER        := 1; 
BEGIN 
   DBMS_OUTPUT.PUT_LINE('------------ BFILE DISPLAY EXAMPLE ------------');
   /* Opening the BFILE: */ 
   DBMS_LOB.OPEN (file_loc, DBMS_LOB.LOB_READONLY); 
   LOOP 
      DBMS_LOB.READ (file_loc, Amount, Position, Buffer); 
      /* Display the buffer contents: */ 
      DBMS_OUTPUT.PUT_LINE(substr(utl_raw.cast_to_varchar2(Buffer), 1, 250));
      Position := Position + Amount; 
   END LOOP; 
   /* Closing the BFILE: */ 
   DBMS_LOB.CLOSE (file_loc); 
   EXCEPTION 
   WHEN NO_DATA_FOUND THEN 
      DBMS_OUTPUT.PUT_LINE('End of data'); 
END;
/
SHOW ERRORS;

