/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/finsert.sql */

/* Inserting  row containing a BFILE by initializing a BFILE locator */
   
CREATE OR REPLACE PROCEDURE insertBFILE_proc IS
  /* Initialize the BFILE locator: */ 
  Lob_loc  BFILE := BFILENAME('MEDIA_DIR', 'keyboard_logo.jpg');
BEGIN
    DBMS_OUTPUT.PUT_LINE('------------ BFILE INSERT EXAMPLE ------------');
    INSERT INTO print_media
    (product_id, ad_id, ad_graphic) VALUES (3106, 13002, Lob_loc);
END;
/

