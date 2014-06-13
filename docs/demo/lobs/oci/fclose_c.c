/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fclose_c.c */

/* Closing a BFILE with CLOSE.  */
#include <oratypes.h>
#include "lobdemo.h"
void BfileLobClose_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                        OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
   printf ("----------- OCILobOpen Demo --------------\n");
   checkerr(errhp, OCILobOpen(svchp, errhp, Bfile_loc,
                    (ub1) OCI_LOB_READONLY));

   checkerr(errhp, OCILobClose(svchp, errhp, Bfile_loc));
}
