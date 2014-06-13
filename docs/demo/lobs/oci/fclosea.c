/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fclosea.c */

/* Closing all open BFILEs. */
#include <oratypes.h>
#include "lobdemo.h"
void BfileCloseAll_proc(OCILobLocator *Bfile_loc1, OCILobLocator *Bfile_loc2, 
                        OCIEnv *envhp, OCIError *errhp, OCISvcCtx *svchp,
                        OCIStmt *stmthp)
{ 
   printf ("----------- OCILobFileCloseAll Demo --------------\n"); 
   checkerr(errhp, OCILobFileOpen(svchp, errhp, Bfile_loc1,
                   (ub1) OCI_LOB_READONLY));

   checkerr(errhp, OCILobFileOpen(svchp, errhp, Bfile_loc2,
                   (ub1) OCI_LOB_READONLY));

   checkerr(errhp, OCILobFileCloseAll(svchp, errhp));
}
