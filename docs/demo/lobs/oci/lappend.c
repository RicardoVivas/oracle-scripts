/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lappend.c */

/* Appending one LOB to another. */
/* This function appends the Source LOB to the end of the Destination LOB */
#include <oratypes.h>
#include "lobdemo.h"
void appendLOB_proc(OCILobLocator *Lob_loc1, OCILobLocator *Lob_loc2,
                    OCIEnv *envhp, OCIError *errhp, OCISvcCtx *svchp, 
                    OCIStmt *stmthp)
{
  printf ("----------- OCILobAppend Demo --------------\n");    
  /* Opening the LOBs is Optional */
  checkerr (errhp, OCILobOpen(svchp, errhp, Lob_loc2, OCI_LOB_READWRITE)); 
  checkerr (errhp, OCILobOpen(svchp, errhp, Lob_loc1, OCI_LOB_READONLY));
  
  /* Append Source LOB to the end of the Destination LOB. */
  printf(" append the source Lob to the destination Lob\n");
  checkerr(errhp, OCILobAppend(svchp, errhp, Lob_loc2, Lob_loc1));

  /* Closing the LOBs is Mandatory if they have been Opened */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc2));
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc1));
  return;
}
