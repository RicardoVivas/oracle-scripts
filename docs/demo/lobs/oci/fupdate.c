/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fupdate.c */

/* Updating a BFILE by initializing a BFILE locator. */
#include <oratypes.h>
#include "lobdemo.h"
void BfileUpdate_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                      OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
  OCIBind *bndhp, *bndhp2; 

  text  *updstmt =  
    (text *) "UPDATE Print_media SET ad_graphic = :Lob_loc \
              WHERE product_id = 3107 AND ad_id = 13002"; 

  OraText *Dir = (OraText *)"MEDIA_DIR", 
          *Name = (OraText *)"keyboard_logo.jpg"; 

  printf ("----------- OCI BFILE Update Demo --------------\n"); 
  /* Prepare the SQL statement: */ 
  checkerr (errhp, OCIStmtPrepare(stmthp, errhp, updstmt,  (ub4)  
                                  strlen((char *) updstmt), 
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
  printf("Bfile column updated \n");
}
