/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lcopy.c */

/* This function copies part of the Source LOB into a specified position
   in the destination LOB 
 */
#include <oratypes.h>
#include "lobdemo.h"

void copyAllPartLOB_proc(OCILobLocator *Lob_loc1, OCILobLocator *Lob_loc2,
                    OCIEnv *envhp, OCIError *errhp, OCISvcCtx *svchp, 
                    OCIStmt *stmthp)
{
  oraub8 Amount = 100;                                  /* <Amount to Copy> */
  oraub8 Dest_pos = 100;                  /*<Position to start copying into> */
  oraub8 Src_pos = 1;                    /* <Position to start copying from> */
  printf ("----------- OCILobCopy Demo --------------\n");    

  /* Opening the LOBs is Optional */
  printf (" open the destination locator (optional)\n");
  checkerr (errhp, OCILobOpen(svchp, errhp, Lob_loc2, OCI_LOB_READWRITE)); 
  printf (" open the source locator (optional)\n");
  checkerr (errhp, OCILobOpen(svchp, errhp, Lob_loc1, OCI_LOB_READONLY));
  
  printf (" copy the lob (amount) from the source to destination\n");
  checkerr (errhp, OCILobCopy2(svchp, errhp, Lob_loc2, Lob_loc1,
                               Amount, Dest_pos, Src_pos));

  /* Closing the LOBs is Mandatory if they have been Opened */
  printf(" close the locators\n");
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc2));
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc1));

  return;
}
