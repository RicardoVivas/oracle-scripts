/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lcnvblob.sql */

/* Procedure lobConvToBlob_proc is not part of the DBMS_LOB package: */

CREATE OR REPLACE PROCEDURE lobConvToBlob_proc 
        (src_loc IN CLOB, dst_loc IN OUT BLOB) IS
  amt         number;
  src_offset  number := 1 ;
  dst_offset  number := 1 ;
  lang_ctx    number := dbms_lob.default_lang_ctx;
  warning     number;
BEGIN
  DBMS_OUTPUT.PUT_LINE('------------ LOB CONVERTTOBLOB EXAMPLE ------------');

  amt := dbms_lob.getlength(src_loc);
  /* The default_csid can be used when the same CLOB/NCLOB charset is used as 
   * the BLOB encoding
   */
  dbms_output.put_line(' Amount specified ' || amt );
  dbms_lob.convertToBlob(dst_loc, src_loc, amt, dst_offset, src_offset,
                         dbms_lob.default_csid, lang_ctx, warning);

  dbms_output.put_line(' Number of characters read from source: ' ||
       (src_offset-1));
  dbms_output.put_line(' Number of bytes written to destination: ' || 
      (dst_offset-1) );
  if (warning = dbms_lob.warn_inconvertible_char) 
  then
    dbms_output.put_line('Warning: Inconvertible character');
  end if;
END;
/
