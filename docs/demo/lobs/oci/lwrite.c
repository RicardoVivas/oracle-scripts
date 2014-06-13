/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lwrite.c */

/* Writing data to a LOB.
   Using OCI you can write arbitrary amounts of data
   to an Internal LOB in either a single piece or in multiple pieces using
   streaming with standard polling. A dynamically allocated Buffer  
   holds the data being written to the LOB. */
#include <oratypes.h>
#include "lobdemo.h"
void writeLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                   OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp, 
                   oraub8 amt_to_write)
{
  /* <total amount of data to write to the CLOB in bytes> */
  oraub8 amt;
  oraub8 offset;
  unsigned int remainder, nbytes;
  boolean last;
  ub1 bufp[MAXBUFLEN];
  sword err;
  oraub8 lob_len;

  printf ("----------- OCILobWrite Demo --------------\n");
  /* Open the CLOB */
  checkerr (errhp, (OCILobOpen(svchp, errhp, Lob_loc, OCI_LOB_READWRITE)));
  if (amt_to_write > MAXBUFLEN)
    nbytes = MAXBUFLEN;        /* We will use streaming via standard polling */
  else
    nbytes = (unsigned int)amt_to_write;  /* Only a single write is required */

  /* Fill in all a's */
  memset((void *)bufp, 'a', MAXBUFLEN);
  
  /* Fill the buffer with nbytes worth of data */
  remainder = (unsigned int)(amt_to_write - nbytes);

  /* Setting Amount to 0 streams the data until use specifies OCI_LAST_PIECE */
  amt = 0;                                  
  offset = 1;  

  /* check lob length before update */
  checkerr (errhp, OCILobGetLength2(svchp, errhp, Lob_loc, &lob_len));
  printf(" Lob length before update = %d\n", (ub4)lob_len);


  if (0 == remainder)
  {
    printf(" writing the Lob data in one-piece mode\n");
    amt = (oraub8)nbytes;
    /* Here, (amt_to_write <= MAXBUFLEN ) so we can write in one piece */
    checkerr (errhp, OCILobWrite2(svchp, errhp, Lob_loc, &amt, NULL,
                                  offset, (void *)bufp, nbytes,
                                  OCI_ONE_PIECE, (void *)0,
                                  (OCICallbackLobWrite2)0,
                                  0, SQLCS_IMPLICIT));
  }    
  else
  {
    printf(" writing the Lob data in streaming polling mode\n");
    /* Here (amt_to_write > MAXBUFLEN ) so we use streaming via standard 
       polling */
    /* write the first piece.  Specifying first initiates polling. */
    err =  OCILobWrite2(svchp, errhp, Lob_loc, &amt, NULL,
                        offset, (void *)bufp, nbytes,
                        OCI_FIRST_PIECE, (void *)0, 
                        (OCICallbackLobWrite2) 0,
                        0, SQLCS_IMPLICIT);

    printf("  1st call. amt returned = %d\n", (ub4)amt);
    if (err != OCI_NEED_DATA)
      checkerr (errhp, err);
    last = FALSE;
    /* Write the next (interim) and last pieces */
    do 
    {
      if (remainder > MAXBUFLEN)
        nbytes = MAXBUFLEN;            /* Still have more pieces to go */
      else
      {
        nbytes = remainder;      /* Here, (remainder <= MAXBUFLEN) */
        last = TRUE;             /* This is going to be the final piece */
      }

      /* Fill the Buffer with nbytes worth of data */
      if (last)
      {
        /* Specifying LAST terminates polling */
        err = OCILobWrite2(svchp, errhp, Lob_loc, &amt, NULL,
                           offset, (void *)bufp, nbytes,
                           OCI_LAST_PIECE, (void *)0, 
                           (OCICallbackLobWrite2) 0,
                           0, SQLCS_IMPLICIT);
        printf("  last call. amt returned = %d\n", (ub4)amt);
        if (err != OCI_SUCCESS)
          checkerr(errhp, err);
      }
      else
      {
        err = OCILobWrite2(svchp, errhp, Lob_loc, &amt, NULL,
                           offset, (void *)bufp, nbytes,
                           OCI_NEXT_PIECE, (void *)0, 
                           (OCICallbackLobWrite2) 0,
                           0, SQLCS_IMPLICIT);
        printf("  subsequent call. amt returned = %d\n", (ub4)amt);

        if (err != OCI_NEED_DATA)
          checkerr (errhp, err);
      }
      /* Determine how much is left to write */
      remainder = remainder - nbytes;
    } while (!last);
  }

  /* check lob length after update */
  checkerr (errhp, OCILobGetLength2(svchp, errhp, Lob_loc, &lob_len));
  printf(" Lob length after update = %d\n", (ub4)lob_len);

  /* At this point, (remainder == 0) */
  
  /* Closing the LOB is mandatory if you have opened it */
  checkerr (errhp, OCILobClose(svchp, errhp, Lob_loc));

  return;
 }
