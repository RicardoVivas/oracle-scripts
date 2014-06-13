/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lerase.c */

/* Erasing part of a LOB (persistent LOBs) */
#include <oratypes.h>
#include "lobdemo.h"
void eraseLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                  OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  oraub8 amount = 300;
  oraub8 offset = 10;

  printf ("----------- OCILobErase Demo --------------\n");     
  /* Open the CLOB: */
  checkerr (errhp, (OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READWRITE)));

  /* Erase the data starting at the specified Offset: */
  printf(" erase %d bytes at offset %d from the Lob\n", (ub4)amount, (ub4)offset); 
  checkerr (errhp, OCILobErase2(svchp, errhp, Lob_loc, &amount, offset ));

  /* Closing the CLOB is mandatory if you have opened it: */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));

  return;
}
