/* Copyright (c) 2004, Oracle. All rights reserved.  */

/*

   NAME
     lwritearr.c - LOB Array Write 

   DESCRIPTION
     Interfaces to demonstrate LOB Array Write feature

   EXPORT FUNCTION(S)
     writeArrayLOB_proc - Demonstrate writing data using an array
                          of lob locators with
                            a] Single piece write
                            b] polling 
                            c] callback
   INTERNAL FUNCTION(S)
     None

   STATIC FUNCTION(S)
     pollingArrayWrite  - Writes data from multiple locators using polling
     callbackArrayWrite - Writes data from multiple locators using callback

   NOTES
     This file is installed in the following path when you install
     the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lwritearr.c

   MODIFIED   (MM/DD/YY)
   aliu        11/03/04 - remove s.h for shiphome 
   debanerj    07/15/04 - lrg1716922
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
static void pollingArrayWrite(OCILobLocator **loc_arr, OCIEnv *envhp,
                              OCIError *errhp, OCISvcCtx *svchp);

static void callbackArrayWrite(OCILobLocator **loc_arr, OCIEnv *envhp,
                               OCIError* errhp, OCISvcCtx *svchp);

static sb4 lobArrayCallback(dvoid *ctxp, ub4 array_iter, dvoid *bufp,
                    oraub8 *lenp, ub1 *piecep, dvoid **changed_bufpp,
                    oraub8 *changed_lenp);


/* Writing LOB data. This example writes into the array of 5 CLOB
 * locators piecewise using a buffer array using standard polling
 * method.
 */
static void pollingArrayWrite(OCILobLocator **loc_arr, OCIEnv *envhp,
                             OCIError *errhp, OCISvcCtx *svchp)
{
  ub1    *bufp_arr[ARRAY_SIZE];
  oraub8  buflen_arr[ARRAY_SIZE];
  oraub8  amt_arr[ARRAY_SIZE];
  oraub8  offset_arr[ARRAY_SIZE];
  ub4     cur_iter;
  ub4     index, index2;

  /* Initialize input array elements */
  for (index=0; index<ARRAY_SIZE; index++)
  {
    bufp_arr[index] = (ub1 *)malloc(MAXBUFLEN);
    memset((void *)bufp_arr[index], 'a', MAXBUFLEN);
    buflen_arr[index] = MAXBUFLEN;
    amt_arr[index] = MAXBUFLEN;
    offset_arr[index] = 1;
  }
  cur_iter = ARRAY_SIZE;

  printf ("  ---------- OCILobArrayWrite one-piece mode  -------------\n");
  checkerr(errhp, OCILobArrayWrite(svchp, errhp, &cur_iter, loc_arr, NULL,
                                  amt_arr, offset_arr, (void *)bufp_arr,
                                  buflen_arr, OCI_ONE_PIECE, (void *)0,
                                  (OCICallbackLobArrayWrite) 0, (ub2) 0,
                                  (ub1) SQLCS_IMPLICIT));

  for (index=1; index<=ARRAY_SIZE; index++)
    printf ("  Locator %d Amount written= %d\n", index, (ub4)amt_arr[index-1]);

  printf ("  ---------- OCILobArrayWrite polling mode  -------------\n");
 /* Process the data in pieces */
  printf("  process the data in pieces\n");

  /* Re-initialize input array elements */
  for (index=0; index<ARRAY_SIZE; index++)
  {
    buflen_arr[index] = MAXBUFLEN;
    amt_arr[index] = 0;       /* Write till last piece */
    offset_arr[index] = 1;
  }
  cur_iter = ARRAY_SIZE;

  for (index=0; index<ARRAY_SIZE; index++)
  {
    checkerr(errhp, OCILobArrayWrite(svchp, errhp, &cur_iter, loc_arr, NULL,
                                     amt_arr, offset_arr, (void *)bufp_arr,
                                     buflen_arr, OCI_FIRST_PIECE, (void *)0,
                                     (OCICallbackLobArrayWrite) 0, (ub2) 0,
                                     (ub1) SQLCS_IMPLICIT));

    printf ("  Locator %d piece = first Amount written = %d\n", cur_iter,
                                          (ub4)amt_arr[cur_iter - 1]);

    for (index2=2; index2<10; index2++)
    {
      checkerr(errhp, OCILobArrayWrite(svchp, errhp, &cur_iter, loc_arr, NULL,
                                       amt_arr, offset_arr, (void *)bufp_arr,
                                       buflen_arr, OCI_NEXT_PIECE, (void *)0,
                                       (OCICallbackLobArrayWrite) 0, (ub2) 0,
                                       (ub1) SQLCS_IMPLICIT));

      printf ("  Locator %d piece = %d : Amount written = %d\n", cur_iter,
                                      index2, (ub4)amt_arr[cur_iter - 1]);
    }
    checkerr(errhp, OCILobArrayWrite(svchp, errhp, &cur_iter, loc_arr, NULL,
                                     amt_arr, offset_arr, (void *)bufp_arr,
                                     buflen_arr, OCI_LAST_PIECE, (void *)0,
                                     (OCICallbackLobArrayWrite) 0, (ub2) 0,
                                     (ub1) SQLCS_IMPLICIT));
    printf ("  Locator %d piece = Last : Amount written = %d\n", cur_iter,
                                              (ub4)amt_arr[cur_iter - 1]);
  }
  /* Free the buffers */
  for (index=0; index<ARRAY_SIZE; index++)
    free(bufp_arr[index]);
}

static sb4 lobArrayCallback(dvoid *ctxp, ub4 array_iter, dvoid *bufp,
                    oraub8 *lenp, ub1 *piecep, dvoid **changed_bufpp,
                    oraub8 *changed_lenp)
{
  struct cbk_context *ctx = (struct cbk_context*)ctxp;

  /* Set piece value appropriately.Write 5pieces 
   * for each locator here.
   */
  printf ("  Locator %d piece = %d written \n", array_iter, ctx->cbk_count);
  if (ctx->cbk_count == 4)
    *piecep = OCI_LAST_PIECE;
  else if (ctx->cbk_count == 5)
  {
    *piecep = OCI_FIRST_PIECE;
    ctx->cbk_count = 0;
  }
  else
    *piecep = OCI_NEXT_PIECE;

  ctx->cbk_count++;
  memset((void *)bufp, 'b', (size_t)(*lenp));
  return OCI_CONTINUE;
} 

static void callbackArrayWrite(OCILobLocator **loc_arr, OCIEnv *envhp,
                              OCIError* errhp, OCISvcCtx *svchp)
{
  ub1    *bufp_arr[ARRAY_SIZE];
  oraub8  buflen_arr[ARRAY_SIZE];
  oraub8  amt_arr[ARRAY_SIZE];
  oraub8  offset_arr[ARRAY_SIZE];
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

  printf ("  ---------- OCILobArrayWrite with callback -------------\n");
  checkerr(errhp, OCILobArrayWrite(svchp, errhp, &cur_iter, loc_arr, NULL,
                                   amt_arr, offset_arr, (void *)bufp_arr,
                                   buflen_arr, OCI_FIRST_PIECE,
                                   (void *)&ctx, lobArrayCallback,
                                   (ub2) 0, (ub1) SQLCS_IMPLICIT));

  for (index=1; index<=ARRAY_SIZE; index++)
    printf ("  Locator %d Total Amount written= %d\n", index, (ub4)amt_arr[index-1]);
}

void writeArrayLOB_proc(OCILobLocator **loc_arr, OCIEnv *envhp,
                       OCIError *errhp, OCISvcCtx *svchp)

{
  printf ("----------- OCILobArrayWrite Demo  --------------\n");
  /* One-piece and Polling mode */
  pollingArrayWrite(loc_arr, envhp, errhp, svchp);
  /* Callback mode */
  callbackArrayWrite(loc_arr, envhp, errhp, svchp);
}

/* end of file lwritearr.c */
