/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lgetchar.c */

/* Getting character set id */
/* This function takes a valid LOB locator and prints the character set id of 
   the LOB. */
#include <oratypes.h>
#include "lobdemo.h"
void getCsidLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                     OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  ub2 charsetid =0 ;
  printf ("----------- OCILobCharSetID Demo --------------\n");

  printf (" get the character set id of adfltextn_locator\n");
  /* Get the charactersid ID of the LOB*/
  checkerr (errhp, OCILobCharSetId(envhp, errhp, Lob_loc, &charsetid));
  printf(" character Set ID of ad_fltextn is : %d\n", charsetid);
  
  return;
}
