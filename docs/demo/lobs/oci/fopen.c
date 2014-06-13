/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fopen.c */

/* Opening a BFILE with OPEN.  */
#include <oratypes.h>
#include "lobdemo.h"
void BfileLobOpen_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                        OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
     printf ("----------- OCILobOpen BFILE Demo --------------\n");
     checkerr(errhp, OCILobOpen(svchp, errhp, Bfile_loc, 
                                (ub1)OCI_FILE_READONLY));
     /* ... Do some processing. */
     checkerr(errhp, OCILobClose(svchp, errhp, Bfile_loc));
}
