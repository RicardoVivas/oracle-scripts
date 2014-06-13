/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lloaddat.sql */

/* Procedure loadLOBFromBFILE_proc is not part of the DBMS_LOB package: */

/* loading a lob with bfile data */

CREATE OR REPLACE PROCEDURE loadLOBFromBFILE_proc (Dest_loc IN OUT BLOB) IS
   /* Note: Dest_loc can be a persistent or temporary LOB */
   Src_loc        BFILE := BFILENAME('MEDIA_DIR', 'keyboard_logo.jpg');
   Amount         INTEGER := 4000;
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ LOB LOADFORMFILE EXAMPLE ------------');
   /* Opening the BFILE is mandatory: */
   DBMS_LOB.OPEN(Src_loc, DBMS_LOB.LOB_READONLY);
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN(Dest_loc, DBMS_LOB.LOB_READWRITE);
   DBMS_LOB.LOADFROMFILE(Dest_loc, Src_loc, Amount);
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE(Dest_loc);
   DBMS_LOB.CLOSE(Src_loc);
END;
/
SHOW ERRORS;

