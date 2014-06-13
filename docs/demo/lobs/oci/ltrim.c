/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/ltrim.c */

/* Trimming LOB data */
#include <oratypes.h>
#include "lobdemo.h"
void trimLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                  OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  oraub8 trimLength;

  printf ("----------- OCILobTrim Demo --------------\n");

  /* Open the CLOB */
  checkerr (errhp, (OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READWRITE)));

  /* Trim the LOB to its new length */
  trimLength = 200;                      /* <New truncated length of the LOB>*/

  printf (" trim the lob to %d bytes\n", (ub4)trimLength);
  checkerr (errhp, OCILobTrim2(svchp, errhp, Lob_loc, trimLength ));

  /* Closing the CLOB is mandatory if you have opened it */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));
}
