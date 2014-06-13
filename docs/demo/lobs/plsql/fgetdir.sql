/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/fgetdir.sql */

/* Getting the directory alias and filename of a BFILE*/

CREATE OR REPLACE PROCEDURE getNameBFILE_proc IS
   file_loc        BFILE;
   DirAlias_name   VARCHAR2(30);
   File_name       VARCHAR2(40);
BEGIN
   DBMS_OUTPUT.PUT_LINE('------------ BFILE FILEGETNAME EXAMPLE ------------');
   SELECT ad_graphic INTO file_loc FROM Print_media 
         WHERE product_id = 3060 AND ad_id = 11001;
   DBMS_LOB.FILEGETNAME(file_loc, DirAlias_name, File_name);
   /* DirAlias_name and File_name now store the DIRECTORY alias and filename */ 
END;
/
SHOW ERRORS;

