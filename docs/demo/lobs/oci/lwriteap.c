/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lwriteap.c */

/* Write-appending to a LOB */
#include <oratypes.h>
#include "lobdemo.h"
void writeAppendLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                  OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  oraub8 amt;
  oraub8 offset;
  sword retval;
  ub1 bufp[MAXBUFLEN];
  oraub8 buflen;

  printf ("----------- OCILobWriteAppend Demo --------------\n"); 
  /* Open the CLOB: */
  checkerr (errhp, (OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READWRITE)));

  /* Setting the amt to the buffer length.  Note here that amt is in chars
     since we are using a CLOB: */
  amt    = sizeof(bufp); 
  buflen = sizeof(bufp);

  /* Fill bufp with data: */
  memset((void *)bufp, 'a', (size_t)buflen);

  /* Write the data from the buffer at the end of the LOB: */
  printf(" write-append data to the frame Lob\n");
  checkerr (errhp, OCILobWriteAppend2(svchp, errhp, Lob_loc, NULL,
                             &amt, (void *)bufp, buflen,
                             OCI_ONE_PIECE, (void *)0,
                             (OCICallbackLobWrite2) 0,
                             0, SQLCS_IMPLICIT));

  /* Closing the CLOB is mandatory if you have opened it: */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));
  return;
}
