/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/fread.c */

/* Reading data from a BFILE. */
#include <oratypes.h>
#include "lobdemo.h"
void BfileRead_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                        OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
   ub1 bufp[MAXBUFLEN];
   oraub8 buflen, amt, offset;
   ub4 retval;
   ub1 piece;

   boolean done;

   printf ("----------- OCILobRead BFILE Demo --------------\n"); 
   checkerr(errhp, OCILobFileOpen(svchp, errhp, Bfile_loc, 
                                   OCI_FILE_READONLY));

   /* This example will READ the entire contents of a BFILE piecewise into a
      buffer using a standard polling method, processing each buffer piece
      after every READ operation until the entire BFILE has been read. */
   /* Setting amt = 0 will read till the end of LOB*/
   amt = 0;
   buflen = sizeof(bufp);
   /* Process the data in pieces */
   offset = 1;
   memset((void *)bufp, '\0', MAXBUFLEN);
   piece = OCI_FIRST_PIECE;
   done = FALSE;
   
  while (!done)
  {
    retval = OCILobRead2(svchp, errhp, Bfile_loc, &amt, NULL, offset,
                         (void *) bufp, buflen, piece, (void *)0,
                         (OCICallbackLobRead2) 0,
                         (ub2) 0, (ub1) SQLCS_IMPLICIT);
    switch (retval)
    {
    case OCI_SUCCESS:             /* Only one piece  since amtp == bufp */
      /* Process the data in bufp. amt will give the amount of data just read in 
         bufp is in bytes. */
      printf(" amt read=%d in the last call\n", (ub4)amt);
      done = TRUE;
     break;
    case OCI_ERROR:
      /*   report_error();        this function is not shown here */
      done = TRUE;
      break;
    case OCI_NEED_DATA:
      printf(" amt read=%d\n", (ub4)amt);
      piece = OCI_NEXT_PIECE;
      break;
    default:
      (void) printf("Unexpected ERROR: OCILobRead2() LOB.\n");
       done = TRUE;
       break;
    }
  }

  /* Closing the BFILE is mandatory if you have opened it */
  checkerr (errhp, OCILobFileClose(svchp, errhp, Bfile_loc));
}

