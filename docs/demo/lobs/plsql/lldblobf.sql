/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lldblobf.sql */

CREATE OR REPLACE PROCEDURE loadBLOB_proc (dst_loc IN OUT BLOB) IS
  src_loc     BFILE := bfilename('MEDIA_DIR','keyboard_logo.jpg') ;
  src_offset  NUMBER := 1;
  dst_offset  NUMBER := 1;
  src_osin    NUMBER;
  dst_osin    NUMBER;
  bytes_rd    NUMBER;
  bytes_wt    NUMBER; 
BEGIN
  DBMS_OUTPUT.PUT_LINE('------------ LOB LOADBLOBFORMFILE EXAMPLE ------------');
  /* Opening the source BFILE is mandatory */
  dbms_lob.fileopen(src_loc, dbms_lob.file_readonly);

  /* Opening the LOB is optional */
  dbms_lob.OPEN(dst_loc, dbms_lob.lob_readwrite);
  /* Save the input source/destination offsets */
  src_osin := src_offset;
  dst_osin := dst_offset;
  /* Use LOBMAXSIZE to indicate loading the entire BFILE */
  dbms_lob.LOADBLOBFROMFILE(dst_loc,src_loc,dbms_lob.lobmaxsize,src_offset,dst_offset) ;

  /* Closing the LOB is mandatory if you have opened it */
  dbms_lob.close(dst_loc);
  dbms_lob.filecloseall();

  /* Use the src_offset returned to calculate the actual amount read from the BFILE */
  bytes_rd := src_offset - src_osin;
  dbms_output.put_line(' Number of bytes read from the BFILE ' || bytes_rd ) ;
  /* Use the dst_offset returned to calculate the actual amount written to the BLOB */
  bytes_wt := dst_offset - dst_osin;
  dbms_output.put_line(' Number of bytes written to the BLOB ' || bytes_wt ) ;
  /* If there is no exception the number of bytes read should equal to the number of bytes written */

END;
/
