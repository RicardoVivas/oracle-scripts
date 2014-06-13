/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lldclobs.sql */

CREATE OR REPLACE PROCEDURE loadCLOB2_proc (dst_loc1 IN OUT NCLOB,
                                             dst_loc2 IN OUT NCLOB) IS
  src_loc     bfile := bfilename('MEDIA_DIR','monitor_3060.txt');
  amt         number := 100;
  src_offset  number := 1;
  dst_offset  number := 1;
  src_osin    number;
  cs_id       number := NLS_CHARSET_ID('JA16TSTSET'); /* 998 */
  lang_ctx    number := dbms_lob.default_lang_ctx;
  warning     number;
BEGIN
  DBMS_OUTPUT.PUT_LINE('------------ LOB LOADCLOBFORMFILE EXAMPLE ------------');
  dbms_lob.fileopen(src_loc, dbms_lob.file_readonly);
  dbms_output.put_line(' BFILE csid is ' || cs_id) ;

  /* Load the first 1KB of the BFILE into dst_loc1 */
  dbms_output.put_line(' ----------------------------' ) ;
  dbms_output.put_line('   First load  ' ) ;
  dbms_output.put_line(' ----------------------------' ) ;

  dbms_lob.LOADCLOBFROMFILE(dst_loc1, src_loc, amt, dst_offset, src_offset,
      cs_id, lang_ctx, warning);

  /* the number bytes read may or may not be 1k */
  dbms_output.put_line(' Amount specified ' || amt ) ;
  dbms_output.put_line(' Number of bytes read from source: ' || 
      (src_offset-1));
  dbms_output.put_line(' Number of characters written to destination: ' ||
      (dst_offset-1) );
  if (warning = dbms_lob.warn_inconvertible_char) 
  then
    dbms_output.put_line('Warning: Inconvertible character');
  end if;

  /* load the next 1KB of the BFILE into the dst_loc2 */
  dbms_output.put_line(' ----------------------------' ) ;
  dbms_output.put_line('   Second load  ' ) ;
  dbms_output.put_line(' ----------------------------' ) ;


  /* Notice we are using the src_offset and lang_ctx returned from the previous
   * load. We do not use value 1001 as the src_offset here because sometimes the
   * actual amount read may not be the same as the amount specified.
   */

  src_osin := src_offset;
  dst_offset := 1;
  dbms_lob.LOADCLOBFROMFILE(dst_loc2, src_loc, amt, dst_offset, src_offset,
      cs_id, lang_ctx, warning);
  dbms_output.put_line(' Number of bytes read from source: ' || 
      (src_offset-src_osin) );
  dbms_output.put_line(' Number of characters written to destination: ' || 
      (dst_offset-1) );
  if (warning = dbms_lob.warn_inconvertible_char)
  then
    dbms_output.put_line('Warning: Inconvertible character');
  end if;

  dbms_lob.filecloseall() ;

END;
/
