/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fexists.c */

/* Checking if a BFILE exists */
#include <oratypes.h>
#include "lobdemo.h"
void BfileExists_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                        OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
   boolean is_exist;

   printf ("----------- OCILobFileExists Demo --------------\n"); 
   checkerr (errhp, OCILobFileExists(svchp, errhp, Bfile_loc, &is_exist));

   if (is_exist == TRUE)
   {
     printf("File exists\n");
   }
   else
   {
     printf("File does not exist\n");
   }
}
