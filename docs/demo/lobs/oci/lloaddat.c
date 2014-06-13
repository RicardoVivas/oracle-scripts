/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lloaddat.c */
#include <oratypes.h>
#include "lobdemo.h"

void loadLOBDataFromBFile_proc(OCILobLocator *Lob_loc, OCILobLocator* BFile_loc, 
                               OCIEnv *envhp,
                               OCIError *errhp, OCISvcCtx *svchp, 
                               OCIStmt *stmthp)
{
  oraub8         amount= 2000;

  printf ("----------- OCILobLoadFromFile Demo --------------\n");

  printf (" open the bfile\n");
  /* Opening the BFILE locator is Mandatory */
  checkerr (errhp, (OCILobOpen(svchp, errhp, BFile_loc, OCI_LOB_READONLY)));

  printf("  open the lob\n");
  /* Opening the CLOB locator is optional */
  checkerr (errhp, (OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READWRITE)));

  /* Load the data from the graphic file (bfile) into the blob */
  printf (" load the LOB from File\n");
  checkerr (errhp, OCILobLoadFromFile2(svchp, errhp, Lob_loc, BFile_loc, 
                                       amount,
                                       (oraub8)1, (oraub8)1));

  /* Closing the LOBs is Mandatory if they have been Opened */
  checkerr (errhp, OCILobClose(svchp, errhp, BFile_loc));
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));

  return;
}
