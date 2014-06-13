/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lread.c */

/* Reading LOB data. This example reads the entire contents of a CLOB
   piecewise into a buffer using a standard polling method, processing
   each buffer piece after every READ operation until the entire CLOB 
   has been read. */

#include <oratypes.h>
#include "lobdemo.h"


static void pollingRead(OCILobLocator *Lob_loc, OCIEnv *envhp,
                        OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  oraub8 amt;
  oraub8 offset;
  sword retval;
  ub1 bufp[MAXBUFLEN];
  oraub8 buflen;
  boolean done;
  ub1 piece;

  buflen = (oraub8)MAXBUFLEN;
  /* Open the CLOB */
  printf(" call OCILobOpen\n");
  checkerr (errhp, OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READONLY));

  printf ("  ---------- OCILobRead one-piece mode  -------------\n");
  offset=1;
  amt = 5;
  checkerr(errhp, OCILobRead2(svchp, errhp, Lob_loc, NULL, &amt, offset,
                              (void *)bufp, buflen, OCI_ONE_PIECE, (void *)0,
                              (OCICallbackLobRead2) 0,
                              (ub2) 0, (ub1) SQLCS_IMPLICIT));
  printf ("  amt read= %d\n", (ub4)amt);
  printf ("  ---------- OCILobRead polling mode  -------------\n");
  /* Setting the amt to the buffer length.  Note here that amt is in chars
     since we are using a CLOB  */
  amt = 0;

 /* Process the data in pieces */
  printf("  process the data in pieces\n");
  offset = 1;
  memset((void *)bufp, '\0', MAXBUFLEN);
  done = FALSE;
  piece = OCI_FIRST_PIECE;

  while (!done)
  {
  retval = OCILobRead2(svchp, errhp, Lob_loc, NULL, &amt, offset,
                       (void *) bufp, buflen, piece, (void *)0,
                       (OCICallbackLobRead2) 0,
                       (ub2) 0, (ub1) SQLCS_IMPLICIT);
  switch (retval)
    {
    case OCI_SUCCESS:             /* Only one piece  since amtp == bufp */
      /* Process the data in bufp. amt will give the amount of data just read in 
         bufp in bytes. */
      printf("  amt read=%d in the last call\n", (ub4)amt);
      done = TRUE;
     break;
    case OCI_ERROR:
      /*   report_error();        this function is not shown here */
      done = TRUE;
      break;
    case OCI_NEED_DATA:
      printf("  amt read=%d\n", (ub4)amt);
      piece = OCI_NEXT_PIECE;
      break;
    default:
      (void) printf("Unexpected ERROR: OCILobRead2() LOB.\n");
       done = TRUE;
       break;
    } 
  }
  /* Closing the CLOB is mandatory if you have opened it */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));
}

struct somestruct 
{ 
  ub4 count; 
};

sb4 lobCallback(dvoid *ctxp, CONST dvoid *bufp, oraub8 len, ub1 piece,
                dvoid **changed_bufpp, oraub8 *changed_lenp)
{
  struct somestruct *ctx = (struct somestruct *)ctxp;
  printf("  In callback, count = %d, len passed in=%d, piece=%d\n",
         ctx->count++,(ub4)len, piece);

  return OCI_CONTINUE;
} 

static void callbackRead(OCILobLocator *Lob_loc, OCIEnv *envhp,
                         OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  oraub8 amt;
  oraub8 offset;
  sword retval;
  ub1 bufp[MAXBUFLEN];
  oraub8 buflen;
  boolean done;

  struct somestruct ctx;

  printf ("  ---------- OCILobRead Callback mode  -------------\n");

  /* Open the CLOB */
  printf("  call OCILobOpen\n");
  checkerr (errhp, OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READONLY));

  /* Setting the amt to the buffer length.  Note here that amt is in chars
     since we are using a CLOB  */
  amt = 0; 
  buflen =(oraub8) sizeof(bufp);

 /* Process the data in pieces */
  printf("  process the data in pieces\n");
  offset = 1;
  memset((void *)bufp, '\0', MAXBUFLEN);
  done = FALSE;

  ctx.count = 0;
  checkerr (errhp, OCILobRead2(svchp, errhp, Lob_loc, NULL, &amt, offset,
                       (void *) bufp, buflen, OCI_FIRST_PIECE,
                       (void *)&ctx, lobCallback,
                       (ub2) 0, (ub1) SQLCS_IMPLICIT));

  printf("  total amt read=%d in OCILobRead2 callback mode\n", (ub4)amt);
  /* Closing the CLOB is mandatory if you have opened it */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));
}

void readLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                  OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)

{
  printf ("----------- OCILobRead Demo  --------------\n");
  /* One-piece and Polling mode */
  pollingRead(Lob_loc, envhp, errhp, svchp, stmthp);
  /* Callback mode */
  callbackRead(Lob_loc, envhp, errhp, svchp, stmthp);
}
