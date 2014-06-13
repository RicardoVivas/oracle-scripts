/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/plsql/lcnvclob.sql */

/* Procedure lobConvToClob_proc is not part of the DBMS_LOB package: */

CREATE OR REPLACE PROCEDURE lobConvToClob_proc 
        (src_loc IN BLOB, dst_loc IN OUT CLOB) IS
  amt         number;
  src_offset  number := 1 ;
  dst_offset  number := 1 ;
  lang_ctx    number := dbms_lob.default_lang_ctx;
  warning     number;
BEGIN
  DBMS_OUTPUT.PUT_LINE('------------ LOB CONVERTTOCLOB EXAMPLE ------------');

  amt := dbms_lob.getlength(src_loc);
  /* The default_csid can be used when the bytes stored in the BLOB are 
   * charset converted to CLOB/NCLOB's charset 
   */
  dbms_output.put_line(' Amount specified ' || amt );
  dbms_lob.convertToClob(dst_loc, src_loc, amt, dst_offset, src_offset,
                         dbms_lob.default_csid, lang_ctx, warning);

  dbms_output.put_line(' Number of bytes read from source: ' ||
       (src_offset-1));
  dbms_output.put_line(' Number of characters written to destination: ' || 
      (dst_offset-1) );
  if (warning = dbms_lob.warn_inconvertible_char)
  then
    dbms_output.put_line('Warning: Inconvertible character');
  end if;
END;
/
