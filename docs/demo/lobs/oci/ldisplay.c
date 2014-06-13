/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/ldisplay.c */

/* Displaying LOB data. This example reads the entire contents of a CLOB 
   piecewise into a buffer using the standard polling method, processing 
   each buffer piece after every READ operation until the entire CLOB 
   has been read. */
#include <oratypes.h>
#include "lobdemo.h"
void displayLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                     OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  oraub8 amt;
  ub4 offset;
  sword retval;
  boolean done;
  ub1 bufp[MAXBUFLEN];
  ub4 buflen;
  ub1 piece;

  printf ("----------- LOB Data Display Demo --------------\n"); 
  /* Open the CLOB */
  printf(" open the lob\n");
  checkerr (errhp, (OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READONLY)));

  /* Setting amt = 0 will read till the end of LOB*/
  amt = 0;
  buflen = sizeof(bufp);

 /* Process the data in pieces */
  printf(" Process the data in pieces\n");
  offset = 1;
  memset((void *)bufp, '\0', MAXBUFLEN);
  done = FALSE;
  piece = OCI_FIRST_PIECE;
  while (!done)
  {
    retval = OCILobRead2(svchp, errhp, Lob_loc, &amt, NULL, offset,
                         (void *) bufp, buflen, piece, (void *)0,
                         (OCICallbackLobRead2) 0,
                         (ub2) 0, (ub1) SQLCS_IMPLICIT);
    switch (retval)
    {
    case OCI_SUCCESS:           /* Only one piece or last piece*/
      /* Process the data in bufp. amt will give the amount of data just read in 
         bufp in bytes.
       */
      done = TRUE;          
      break;
    case OCI_ERROR:
      checkerr (errhp, retval);
      done = TRUE;
      break;
    case OCI_NEED_DATA:         /* There are 2 or more pieces */
      /* Process the data in bufp. amt will give the amount of data just read in 
         bufp in bytes.
       */
      piece = OCI_NEXT_PIECE;
      break;
    default:
      checkerr (errhp, retval);
      done = TRUE;
      break;
    }
  } /* while */

  /* Closing the CLOB is mandatory if you have opened it */
   printf(" close the lob \n");
   checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));
}
