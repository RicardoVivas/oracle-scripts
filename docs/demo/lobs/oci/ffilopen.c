/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/ffilopen.c */

/* Opening a BFILE with FILEOPEN  */
#include <oratypes.h>
#include "lobdemo.h"
void BfileFileOpen_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                        OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
  printf ("----------- OCILobFileOpen Demo --------------\n"); 
  checkerr(errhp, OCILobFileOpen(svchp, errhp, Bfile_loc, 
                                 (ub1)OCI_FILE_READONLY));
  /* ... Do some processing. */
  checkerr(errhp, OCILobFileClose(svchp, errhp, Bfile_loc));
} 
