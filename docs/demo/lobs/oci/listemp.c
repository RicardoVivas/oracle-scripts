/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/listemp.c */

/* Checking if a LOB is temporary.
   This function frees a temporary LOB. It takes a locator as an argument,   
   checks to see if it is a temporary LOB. If it is, the function frees 
   the temporary LOB. Otherwise, it prints out a message saying the locator 
   was not a temporary LOB locator. This function returns 0 if it 
   completes successfully, -1 otherwise: */ 
#include <oratypes.h>
#include "lobdemo.h"
void isTempLOBAndFree_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp, 
                           OCISvcCtx *svchp, OCIStmt *stmthp)
{
  boolean is_temp;
  is_temp = FALSE;
  printf ("-----------  OCILobIsTemporary and OCILobFreeTemporary Demo \
--------------\n");
  checkerr (errhp, OCILobIsTemporary(envhp, errhp, Lob_loc, &is_temp));

  if(is_temp)
  {
      checkerr(errhp, (OCILobFreeTemporary(svchp, errhp, Lob_loc)));
      printf("Temporary LOB freed\n");

  }
  else
  {
      printf("locator is not a temporary LOB locator\n");
  }

}
