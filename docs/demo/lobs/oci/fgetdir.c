/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fgetdir.c */

/* Getting the directory alias and filename */
#include <oratypes.h>
#include "lobdemo.h"
void BfileGetDir_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                      OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
   OraText dir_alias[32];
   OraText filename[256];
   ub2 d_length = 32;
   ub2 f_length = 256;

   printf ("----------- OCILobFileGetName Demo --------------\n"); 
   checkerr(errhp, OCILobFileGetName(envhp, errhp, Bfile_loc,
                       dir_alias, &d_length, filename, &f_length));

   dir_alias[d_length] = '\0';
   filename[f_length] = '\0';
   printf("Directory Alias : [%s]\n", dir_alias);
   printf("File name : [%s]\n", filename);
}
