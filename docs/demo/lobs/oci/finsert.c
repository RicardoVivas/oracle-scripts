/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/finsert.c */

/* Inserting a row by initializing a BFILE Locator. */
#include <oratypes.h>
#include "lobdemo.h"
void BfileInsert_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                      OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)

{
  text  *insstmt = 
     (text *) "INSERT INTO Print_media (product_id, ad_id, ad_graphic) \
         VALUES (2056, 60315, :Lob_loc)";
  OCIBind *bndhp;
  OraText *Dir = (OraText *)"MEDIA_DIR", *Name = (OraText *)"keyboard_logo.jpg";

  printf ("----------- OCI BFILE Insert Demo --------------\n");   
  /* Prepare the SQL statement: */
  checkerr (errhp, OCIStmtPrepare(stmthp, errhp, insstmt,  (ub4) 
                                  strlen((char *) insstmt),
                                  (ub4) OCI_NTV_SYNTAX, (ub4)OCI_DEFAULT));

  checkerr (errhp, OCILobFileSetName(envhp, errhp, &Bfile_loc,
                                     Dir, (ub2)strlen((char *)Dir),
                                     Name,(ub2)strlen((char *)Name)));
  checkerr (errhp, OCIBindByPos(stmthp, &bndhp, errhp, (ub4) 1,
                                (void *) &Bfile_loc, (sb4) 0,  SQLT_BFILE,
                                (void *) 0, (ub2 *)0, (ub2 *)0,
                                (ub4) 0, (ub4 *) 0, (ub4) OCI_DEFAULT));
  /* Execute the SQL statement: */
  checkerr (errhp, OCIStmtExecute(svchp, stmthp, errhp, (ub4) 1, (ub4) 0,
                                  (CONST OCISnapshot*) 0, (OCISnapshot*) 0, 
                                  (ub4) OCI_DEFAULT));
}
