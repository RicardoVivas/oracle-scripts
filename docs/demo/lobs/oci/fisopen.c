/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fisopen.c */

/* Checking if the BFILE is Open with ISOPEN. */
#include <oratypes.h>
#include "lobdemo.h"
void BfileIsOpen_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                      OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
  boolean flag;

   printf ("----------- OCILobIsOpen Demo --------------\n");  
  /* Allocate the locator descriptor */ 
  checkerr(errhp, OCILobOpen(svchp, errhp, Bfile_loc, 
                             (ub1)OCI_FILE_READONLY));
  
  checkerr(errhp, OCILobIsOpen(svchp, errhp, Bfile_loc, &flag));
  
  if (flag == TRUE)
  {
    printf("File is open\n");
  }
  else
  {
    printf("File is not open\n");
  }
  
  checkerr(errhp, OCILobFileClose(svchp, errhp, Bfile_loc));
}
