/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lldclobf.sql */

CREATE OR REPLACE PROCEDURE loadCLOB1_proc (dst_loc IN OUT CLOB) IS
  src_loc     bfile := bfilename('MEDIA_DIR','monitor_3060.txt') ;
  amt         number := dbms_lob.lobmaxsize;
  src_offset  number := 1 ;
  dst_offset  number := 1 ;
  lang_ctx    number := dbms_lob.default_lang_ctx;
  warning     number;
BEGIN
  DBMS_OUTPUT.PUT_LINE('------------ LOB LOADCLOBFORMFILE EXAMPLE ------------');
  dbms_lob.fileopen(src_loc, dbms_lob.file_readonly);

  /* The default_csid can be used when the BFILE encoding is in the same charset
   * as the destination CLOB/NCLOB charset
   */
   dbms_lob.LOADCLOBFROMFILE(dst_loc,src_loc, amt, dst_offset, src_offset,                               
       dbms_lob.default_csid, lang_ctx,warning) ;

  dbms_output.put_line(' Amount specified ' || amt ) ;
  dbms_output.put_line(' Number of bytes read from source: ' || 
      (src_offset-1));
  dbms_output.put_line(' Number of characters written to destination: ' || 
      (dst_offset-1) );
  if (warning = dbms_lob.warn_inconvertible_char) 
  then
    dbms_output.put_line('Warning: Inconvertible character');
  end if;

  dbms_lob.filecloseall() ;
END;
/
