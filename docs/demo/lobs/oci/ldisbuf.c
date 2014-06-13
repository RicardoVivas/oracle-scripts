/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/ldisbuf.c */

/* Disabling LOB buffering (persistent LOBs) */
#include <oratypes.h>
#include "lobdemo.h"
void LOBBuffering_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                       OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  ub4 amt;
  ub4 offset;
  sword retval;
  ub1 bufp[MAXBUFLEN];
  ub4 buflen;
  printf ("----------- OCI LOB Buffering Demo --------------\n");

  /* Open the CLOB: */
  checkerr (errhp, (OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READWRITE)));

  /* Enable LOB Buffering: */
  printf (" enable LOB buffering\n");
  checkerr (errhp, OCILobEnableBuffering(svchp, errhp, Lob_loc));

  printf (" write data to LOB\n");

  /* Write data into the LOB: */
  amt    = sizeof(bufp);
  buflen = sizeof(bufp);
  offset = 1;

  checkerr (errhp, OCILobWrite (svchp, errhp, Lob_loc, &amt, 
                                offset, (void *)bufp, buflen,
                                OCI_ONE_PIECE, (void *)0, 
                                (sb4 (*)(void*,void*,ub4*,ub1 *))0,
                                0, SQLCS_IMPLICIT));

  /* Flush the buffer: */
  printf(" flush the LOB buffers\n");
  checkerr (errhp, OCILobFlushBuffer(svchp, errhp, Lob_loc,
                                     (ub4)OCI_LOB_BUFFER_FREE));

  /* Disable Buffering: */
  printf (" disable LOB buffering\n");
  checkerr (errhp, OCILobDisableBuffering(svchp, errhp, Lob_loc));

  /* Subsequent LOB WRITEs will not use the LOB Buffering Subsystem: */

  /* Closing the CLOB is mandatory if you have opened it: */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));

  return;
}
