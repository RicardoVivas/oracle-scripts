/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/linit.c */

/* Seeing if a LOB locator is initialized */
#include <oratypes.h>
#include "lobdemo.h"

void isInitializedLOB_proc(OCILobLocator *Lob_loc1, OCILobLocator *Lob_loc2,
                           OCIEnv *envhp, OCIError *errhp, OCISvcCtx *svchp, 
                           OCIStmt *stmthp)
{
  boolean       isInitialized;
  printf ("----------- OCILobLocatorIsInit Demo --------------\n");
  /* Determine if the locator 1 is Initialized -: */
  checkerr(errhp, OCILobLocatorIsInit(envhp, errhp, Lob_loc1, &isInitialized));
                                    /* IsInitialized should return TRUE here */
  printf(" for Locator 1, isInitialized = %d\n", isInitialized);

  /* Determine if the locator 2 is Initialized -: */
  checkerr(errhp, OCILobLocatorIsInit(envhp, errhp, Lob_loc2, &isInitialized));
                                    /* IsInitialized should return FALSE here */
  printf(" for Locator 2, isInitialized = %d\n", isInitialized);

  return;
}
