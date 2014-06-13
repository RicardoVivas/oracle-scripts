/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lobdemo.sql */

Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      lobdemo.sql - Usage of various LOB APIs
Rem
Rem    DESCRIPTION
Rem      This file depicts the usage of various LOB APIs for persistent LOBs, 
Rem      temporary LOBs and BFILEs
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CONNECT pm/pm;

set serveroutput on size 200000

-----------------------------------------------------------------------------
---------------------------- Generic procedures -----------------------------
-----------------------------------------------------------------------------

-- load the procedures
@lappend
@lcompare
@lcopy
@lcopyloc
@ldisplay
@lerase
@linstr
@lisopen
@listemp
@llength
@lloaddat
@lread
@lsubstr
@ltrim
@lwrite
@lwriteap
@lldblobf
@lldclobf
@lldclobs
@linsert
@lcnvblob
@lcnvclob

-- calling these APIs
CREATE OR REPLACE PROCEDURE call_lob_apis
  (blob1 IN OUT BLOB, blob2 IN OUT BLOB, clob1 IN OUT CLOB CHARACTER SET ANY_CS, 
  clob2 IN OUT CLOB CHARACTER SET ANY_CS) IS
  /* Note: blob1 should be writable */
BEGIN
  displayLOB_proc(blob1);
  displayLOB_proc(blob2);

  -- append
  appendLOB_proc(blob1, blob2);
  displayLOB_proc(blob1);
  displayLOB_proc(blob2);

  -- compare
  compareTwoLOBs_proc(blob1, blob2);

  -- copy 
  copyLOB_proc(blob1, blob2);
  displayLOB_proc(blob1);
  displayLOB_proc(blob2);

  -- copyloc
  lobAssign_proc(blob2);

  -- erase
  eraseLOB_proc(blob1);
  displayLOB_proc(blob1);
  displayLOB_proc(blob2);

  -- instr
  instringLOB_proc(blob1);

  -- Is Open ?
  lobIsOpen_proc(blob1);

  -- Is Temp ?
  isTempLob_proc(blob1);

  -- Length
  getLengthLOB_proc(blob1);

  -- read
  readLOB_proc(blob1);

  -- substr
  substringLOB_proc(blob1);

  -- trim
  trimLOB_proc(blob1);
  displayLOB_proc(blob1);
  displayLOB_proc(blob2);

  -- write
  writeDataToLOB_proc(blob1);
  displayLOB_proc(blob1);
  displayLOB_proc(blob2);

  -- write append
  lobWriteAppend_proc(blob1);
  displayLOB_proc(blob1);
  displayLOB_proc(blob2);

  -- LoadBlobFromFile
  loadBLOB_proc(blob1);

  -- LoadClobFromFile
  loadCLOB1_proc(clob1);

  -- LoadClobFromFile
  loadCLOB2_proc(clob1, clob2);

  -- ConvertToBlob
  lobConvToBlob_proc(clob1, blob1);

  -- ConvertToClob
  lobConvToClob_proc(blob2, clob1);
 
  -- Insert row containing a LOB
  insertLob_proc(blob1);
END;
/
show errors;

-----------------------------------------------------------------------------
-------------------------  Persistent LOB operations ------------------------
-----------------------------------------------------------------------------

declare
  blob1 BLOB;
  blob2 BLOB;
  clob1 CLOB;
  nclob1 NCLOB;
begin
  SELECT ad_photo INTO blob1 FROM print_media WHERE Product_id = 2268 
        FOR UPDATE;
  SELECT ad_photo INTO blob2 FROM print_media WHERE Product_id = 3106;

  SELECT ad_sourcetext INTO clob1 FROM Print_media
      WHERE product_id=3106 and ad_id=13001 FOR UPDATE;

  SELECT ad_fltextn INTO nclob1 FROM Print_media
      WHERE product_id=3060 and ad_id=11001 FOR UPDATE;

  call_lob_apis(blob1, blob2, clob1, nclob1);
  rollback;
end;
/
show errors;

-----------------------------------------------------------------------------
-------------------------  Temporary LOB operations ------------------------
-----------------------------------------------------------------------------

declare
  blob1 BLOB;
  blob2 BLOB;
  clob1 CLOB;
  nclob1 NCLOB;
begin
  -- create temp LOBs
  DBMS_LOB.CREATETEMPORARY(blob1,TRUE, DBMS_LOB.SESSION);
  DBMS_LOB.CREATETEMPORARY(blob2,TRUE, DBMS_LOB.SESSION);
  DBMS_LOB.CREATETEMPORARY(clob1,TRUE, DBMS_LOB.SESSION);
  DBMS_LOB.CREATETEMPORARY(nclob1,TRUE, DBMS_LOB.SESSION);

  -- fill with data
  writeDataToLOB_proc(blob1);
  writeDataToLOB_proc(blob2);

  -- CHAR->LOB conversion
  clob1 := 'abcde';
  nclob1 := TO_NCLOB(clob1);

  -- Other APIs
  call_lob_apis(blob1, blob2, clob1, nclob1);

  -- free temp LOBs
  DBMS_LOB.FREETEMPORARY(blob1);
  DBMS_LOB.FREETEMPORARY(blob2);
  DBMS_LOB.FREETEMPORARY(clob1);
  DBMS_LOB.FREETEMPORARY(nclob1);

end;
/
show errors;

-----------------------------------------------------------------------------
------------------------------  BFILE operations ----------------------------
-----------------------------------------------------------------------------

@fclose_c
@fclose_f
@fclosea
@fcompare
@fcopyloc
@fdisplay
@fexists
@ffilopen
@ffisopen
@fgetdir
@fisopen
@flength
@fopen
@fpattern
@fread
@freadprt
@fupdate
@finsert

-- update bfiles in print_media;
update print_media set ad_graphic = BFILENAME('MEDIA_DIR','monitor.jpg') where product_id = 3060;
update print_media set ad_graphic = BFILENAME('MEDIA_DIR','mousepad.jpg') where product_id = 2056;
update print_media set ad_graphic = BFILENAME('MEDIA_DIR','keyboard.jpg') where product_id = 3106;  
update print_media set ad_graphic = BFILENAME('MEDIA_DIR','modem.jpg') where product_id = 2268;

-- calling these APIs
CREATE OR REPLACE PROCEDURE BFILE_TESTS IS
BEGIN
  -- Open
  openBFILE_procOne();
  openBFILE_procTwo();

  -- Close
  closeBFILE_procOne();
  closeBFILE_procTwo();

  -- CloseAll
  closeAllOpenBFILEs_proc();

  -- Is Open ?
  seeIfOpenBFILE_procOne();
  seeIfOpenBFILE_procTwo();

  -- File Exists ?
  seeIfExistsBFILE_proc();

  -- Length
  getLengthBFILE_proc();

  -- Read
  readBFILE_proc();

  -- Display
  displayBFILE_proc();

  -- Compare
  compareBFILEs_proc();

  -- Instr/Substr
  instringBFILE_proc();
  substringBFILE_proc();

  -- Assign
  BFILEAssign_proc();
 
  -- GetFileName
  getNameBFILE_proc();

  -- Update BFILE Column
  updateBFILEColumn_proc();
 
  -- Insert BFILE Column
  insertBFILE_proc();
END;
/
show errors;


exec BFILE_TESTS;
