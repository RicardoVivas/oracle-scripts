/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/llength.c */

/* Getting the length of a LOB */
#include <oratypes.h>
#include "lobdemo.h"

/* This function gets the length of the LOB */
void getLengthLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                       OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)

{
  oraub8 length;

  printf("----------- OCILobGetLength Demo --------------\n");
  /* Opening the LOB is Optional */
  printf(" Open the locator (optional)\n");
  checkerr (errhp, (OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READONLY)));
  
  printf(" get the length of ad_fltextn.\n");
  checkerr (errhp, OCILobGetLength2(svchp, errhp, Lob_loc, &length));

  /* Length is undefined if the LOB is NULL or undefined */
  printf(" Length of LOB is %d\n",(ub4)length);

  /* Closing the LOBs is Mandatory if they have been Opened */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));

  return;
}
