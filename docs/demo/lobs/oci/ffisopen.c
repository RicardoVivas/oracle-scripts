/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/ffisopen.c */

/* Checking if the BFILE is open with FILEISOPEN. */
#include <oratypes.h>
#include "lobdemo.h"
void BfileFileIsOpen_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                          OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
  boolean flag;

  printf ("----------- OCILobFileIsOpen Demo --------------\n"); 
  checkerr(errhp, OCILobFileOpen(svchp, errhp, Bfile_loc, 
                                 (ub1)OCI_FILE_READONLY));
  
  checkerr(errhp, OCILobFileIsOpen(svchp, errhp, Bfile_loc, &flag));
  
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
