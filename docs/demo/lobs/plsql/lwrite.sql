/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lwrite.sql */

/* Procedure writeDataToLOB_proc is not part of the DBMS_LOB package: */

/* writing data to a lob */

CREATE or REPLACE PROCEDURE writeDataToLOB_proc (Lob_loc IN OUT BLOB) IS
   /* Note: Lob_loc can be a persistent or temporary LOB */
   Buffer          RAW(32767);
   Amount          BINARY_INTEGER := 10;
   OptimalAmount   BINARY_INTEGER;
   Position        INTEGER := 1;
   i               INTEGER;
   Chunk_size      INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB WRITE EXAMPLE ------------');
   /* For persistent LOBs, for each DBMS_LOB call, 
    * we write data in multiples of chunksize,
    * and write on chunk boundaries. This ensures best performance */
    Chunk_size := DBMS_LOB.GETCHUNKSIZE(Lob_loc);
    OptimalAmount := (Amount/Chunk_size) * Chunk_size;
    if OptimalAmount = 0 then
      OptimalAmount := Amount;
    end if;

   /* Fill a buffer */
   Buffer := hextoraw(lpad('4', Amount*4, '4'));
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READWRITE);
   FOR i IN 1..3 LOOP
      Amount := OptimalAmount;
      DBMS_LOB.WRITE (Lob_loc, Amount, Position, Buffer);
      /* Fill the buffer with more data to write to the LOB: */
      Position := Position + Amount;
   END LOOP;
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (Lob_loc);
END;
/
SHOW ERRORS;

