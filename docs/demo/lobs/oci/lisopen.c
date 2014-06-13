/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lisopen.c */

/* Checking if LOB is Open. */
#include <oratypes.h>
#include "lobdemo.h"
void seeIfLOBIsOpen_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                         OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  boolean isOpen;

  printf ("----------- OCILobIsOpen Demo --------------\n");
  /* See if the LOB is Open */
  checkerr (errhp, OCILobIsOpen(svchp, errhp, Lob_loc, &isOpen));
 
  if (isOpen)
  {
    printf("  Lob is Open\n");
    /* ... Processing given that the LOB has already been Opened */
  }
  else
  {
    printf("  Lob is not Open\n");
    /* ... Processing given that the LOB has not been Opened */
  }
  return;
}
