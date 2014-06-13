/* Copyright (c) 2004, Oracle. All rights reserved.  */

/*

   NAME
     lreadarr.c - LOB Array Read 

   DESCRIPTION
     Interfaces to demonstrate LOB Array Read feature

   EXPORT FUNCTION(S)
     readArrayLOB_proc - Demonstrate reading data from an array
                         of lob locators with
                           a] Single piece read
                           b] polling 
                           c] callback
   INTERNAL FUNCTION(S)
     None

   STATIC FUNCTION(S)
     pollingArrayRead  - Reads data from multiple locators using polling
     callbackArrayRead - Reads data from multiple locators using callback

   NOTES
     This file is installed in the following path when you install
     the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lreadarr.c

   MODIFIED   (MM/DD/YY)
   aliu        11/03/04 - remove s.h for shiphome 
   debanerj    06/04/04 - debanerj_13064_lob_array_read
   debanerj    06/02/04 - Creation

*/

#include <oratypes.h>
#include "lobdemo.h"

/*---------------------------------------------------------------------------
                     PRIVATE TYPES AND CONSTANTS
  ---------------------------------------------------------------------------*/

struct cbk_context 
{ 
  ub4 cbk_count; 
};

/*---------------------------------------------------------------------------
                     STATIC FUNCTION DECLARATIONS 
  ---------------------------------------------------------------------------*/
static void pollingArrayRead(OCILobLocator **loc_arr, OCIEnv *envhp,
                             OCIError *errhp, OCISvcCtx *svchp);

static void callbackArrayRead(OCILobLocator **loc_arr, OCIEnv *envhp,
                              OCIError* errhp, OCISvcCtx *svchp);

static sb4 lobArrayCallback(dvoid *ctxp, ub4 array_iter, CONST dvoid *bufp,
                            oraub8 len, ub1 piece, dvoid **changed_bufpp,
                            oraub8 *changed_lenp);


/* Reading LOB data. This example reads the entire contents of a CLOB
 * 5 LOB locators piecewise into a buffer array using standard polling
 * method, processing each buffer piece after every READ operation
 * until the entire CLOB data for all the locators has been read.
 */
static void pollingArrayRead(OCILobLocator **loc_arr, OCIEnv *envhp,
                             OCIError *errhp, OCISvcCtx *svchp)
{
  ub1    *bufp_arr[ARRAY_SIZE];
  oraub8  buflen_arr[ARRAY_SIZE];
  oraub8  amt_arr[ARRAY_SIZE];
  oraub8  offset_arr[ARRAY_SIZE];
  sword   retval;
  boolean done;
  ub4     cur_iter;
  ub4     prev_iter;
  ub4     piece_count;
  ub4     index;

  /* Initialize input array elements */
  for (index=0; index<ARRAY_SIZE; index++)
  {
    bufp_arr[index] = (ub1 *)malloc(MAXBUFLEN);
    buflen_arr[index] = MAXBUFLEN;
    amt_arr[index] = 10;
    offset_arr[index] = 1;
  }
  cur_iter = ARRAY_SIZE;

  printf ("  ---------- OCILobArrayRead one-piece mode  -------------\n");
  checkerr(errhp, OCILobArrayRead(svchp, errhp, &cur_iter, loc_arr, NULL,
                                  amt_arr, offset_arr, (void *)bufp_arr,
                                  buflen_arr, OCI_ONE_PIECE, (void *)0,
                                  (OCICallbackLobArrayRead) 0, (ub2) 0,
                                  (ub1) SQLCS_IMPLICIT));

  for (index=1; index<=ARRAY_SIZE; index++)
    printf ("  Locator %d Amount read= %d\n", index, (ub4)amt_arr[index-1]);

  printf ("  ---------- OCILobArrayRead polling mode  -------------\n");
 /* Process the data in pieces */
  printf("  process the data in pieces\n");

  done = FALSE;
  piece_count = 1;

  /* Re-initialize input array elements */
  for (index=0; index<ARRAY_SIZE; index++)
  {
    buflen_arr[index] = MAXBUFLEN;
    amt_arr[index] = 0;       /* Read all the data in pieces */
    offset_arr[index] = 1;
  }
  cur_iter = ARRAY_SIZE;

  checkerr(errhp, OCILobArrayRead(svchp, errhp, &cur_iter, loc_arr, NULL,
                                  amt_arr, offset_arr, (void *)bufp_arr,
                                  buflen_arr, OCI_FIRST_PIECE, (void *)0,
                                  (OCICallbackLobArrayRead) 0, (ub2) 0,
                                  (ub1) SQLCS_IMPLICIT));
  printf ("  Locator %d piece = %d Amount read = %d\n", cur_iter, piece_count,
                                                  (ub4)amt_arr[cur_iter - 1]);

  while (!done)
  {
    prev_iter = cur_iter;
    retval = OCILobArrayRead(svchp, errhp, &cur_iter, loc_arr, NULL,
                             amt_arr, offset_arr, (void *)bufp_arr,
                             buflen_arr, OCI_NEXT_PIECE, (void *)0,
                             (OCICallbackLobArrayRead) 0, (ub2) 0,
                             (ub1) SQLCS_IMPLICIT);
    piece_count++;
    switch (retval)
    {
      case OCI_SUCCESS:
        /* Process the data in bufp. amt will give the amount of data just
         * read in bufp in characters.
         */
        printf ("  Locator %d piece = %d Amount read = %d\n", cur_iter,
                              piece_count, (ub4)amt_arr[cur_iter - 1]);
        done = TRUE;
        break;
      case OCI_ERROR:
        /*   report_error();        this function is not shown here */
        done = TRUE;
        break;
      case OCI_NEED_DATA:
        if (cur_iter != prev_iter)
          piece_count = 1;
        printf ("  Locator %d piece = %d Amount read = %d\n", cur_iter,
                              piece_count, (ub4)amt_arr[cur_iter - 1]);
        break;
      default:
        (void) printf("Unexpected ERROR: OCILobArrayRead() LOB.\n");
        done = TRUE;
        break;
    } 
  }
  /* Free the buffers */
  for (index=0; index<ARRAY_SIZE; index++)
    free(bufp_arr[index]);
}

static sb4 lobArrayCallback(dvoid *ctxp, ub4 array_iter, CONST dvoid *bufp,
                              oraub8 len, ub1 piece, dvoid **changed_bufpp,
                              oraub8 *changed_lenp)
{
  struct cbk_context *ctx = (struct cbk_context*)ctxp;
  /* Process the buffer here :  */

  printf ("  Locator %d piece = %d Amount read = %d\n", array_iter,
                                       ctx->cbk_count++, (ub4)len);
  switch (piece)
  {
    case OCI_LAST_PIECE:
      ctx->cbk_count = 1;
      break;
    case OCI_FIRST_PIECE:
      break;
    case OCI_NEXT_PIECE:
      /* --Optional code to set changed_bufpp and changed_lenp
       * if the  buffer needs to be changed dynamically
       */
      break;
    default:
      (void) printf("callback read error: unkown piece = %d.\n", piece);
      return OCI_ERROR;
    }
  return OCI_CONTINUE;
} 

static void callbackArrayRead(OCILobLocator **loc_arr, OCIEnv *envhp,
                              OCIError* errhp, OCISvcCtx *svchp)
{
  ub1    *bufp_arr[ARRAY_SIZE];
  oraub8  buflen_arr[ARRAY_SIZE];
  oraub8  amt_arr[ARRAY_SIZE];
  oraub8  offset_arr[ARRAY_SIZE];
  sword   retval;
  ub4     cur_iter;
  ub4     index;
  struct cbk_context ctx;

  ctx.cbk_count = 1;
  /* Initialize input array elements */
  for (index=0; index<ARRAY_SIZE; index++)
  {
    bufp_arr[index] = (ub1 *)malloc(MAXBUFLEN);
    buflen_arr[index] = MAXBUFLEN;
    amt_arr[index] = 0;
    offset_arr[index] = 1;
  }
  cur_iter = ARRAY_SIZE;

  printf ("  ---------- OCILobArrayRead with callback -------------\n");
  checkerr(errhp, OCILobArrayRead(svchp, errhp, &cur_iter, loc_arr, NULL,
                                  amt_arr, offset_arr, (void *)bufp_arr,
                                  buflen_arr, OCI_FIRST_PIECE,
                                  (void *)&ctx, lobArrayCallback,
                                  (ub2) 0, (ub1) SQLCS_IMPLICIT));

  for (index=1; index<=ARRAY_SIZE; index++)
    printf ("  Locator %d Total Amount read= %d\n", index, (ub4)amt_arr[index-1]);
}

void readArrayLOB_proc(OCILobLocator **loc_arr, OCIEnv *envhp,
                       OCIError *errhp, OCISvcCtx *svchp)

{
  printf ("----------- OCILobArrayRead Demo  --------------\n");
  /* One-piece and Polling mode */
  pollingArrayRead(loc_arr, envhp, errhp, svchp);
  /* Callback mode */
  callbackArrayRead(loc_arr, envhp, errhp, svchp);
}

/* end of file lreadarr.c */
