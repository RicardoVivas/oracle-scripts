/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fcopyloc.c */

/* Copying a LOB locator for a BFILE.  */
#include <oratypes.h>
#include "lobdemo.h"
void BfileAssign_proc(OCILobLocator *Bfile_loc1, OCILobLocator *Bfile_loc2, 
                      OCIEnv *envhp, OCIError *errhp, OCISvcCtx *svchp,
                      OCIStmt *stmthp)
{ 
   printf ("----------- OCI BFILE Assign Demo --------------\n"); 

   checkerr(errhp, OCILobLocatorAssign(svchp, errhp, Bfile_loc1, &Bfile_loc2));
}
