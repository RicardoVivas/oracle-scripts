#include <oratypes.h>
#include "lobdemo.h"

#define DATA_SIZE 5000
#define PIECE_SIZE 1000
#define MAXCOLS 2
#define MAXROWS 10
#define NPIECE DATA_SIZE/PIECE_SIZE
#define MAX_IN_ROWS 10

/* Local structure to store OCI handles used by the demo */
typedef struct lobdemoctx
{
  OCIEnv *envhp;
  OCIServer *srvhp;
  OCISvcCtx *svchp;
  OCIError *errhp;
  OCISession *authp;
  OCIStmt *stmthp;
} lobdemoctx;

/*---------------------------------------------------------------------------
                     PRIVATE TYPES AND CONSTANTS
  ---------------------------------------------------------------------------*/
/* Schema for lob demos */
static text *username = (text *) "pm";
static text *password = (text *) "pm";

/* initialization and clean-up routines */
static void initialize(lobdemoctx *ctxptr);
static void cleanup(lobdemoctx *ctxptr);
/* LOB test driver */
static void call_lob_apis(lobdemoctx *ctx, OCILobLocator *inlob, 
                          OCILobLocator *outlob, OCILobLocator **lob_arr);

/* BFILE test driver */
static void bfile_demos(lobdemoctx *ctx, OCILobLocator *Bfile_loc1,
                        OCILobLocator *Bfile_loc2);

/* Select a lob into a locator variable for update */
static sb4 select_lob_for_update(OCILobLocator *Lob_loc, OCIError *errhp, 
                                 OCISvcCtx *svchp, OCIStmt *stmthp, 
                                 int prod_id, int ad_id);
/* Select a lob into a locator variable for read */
static sb4 select_lob_for_read(OCILobLocator *Lob_loc, OCIError *errhp, 
                               OCISvcCtx *svchp, OCIStmt *stmthp, 
                               int prod_id, int ad_id);

/* Select a bfile into a locator variable for read */
static sb4 select_bfile_for_read(OCILobLocator *Lob_loc, OCIError *errhp, 
                                 OCISvcCtx *svchp, OCIStmt *stmthp, 
                                 OCIEnv *envhp, int prod_id, int ad_id);

/* Select a lobs into a locator array for update */
static sb4 select_lob_array_for_update(OCILobLocator **Lob_loc, OCIError *errhp,
                                       OCISvcCtx *svchp, OCIStmt *stmthp);

/* -------------------------------- main() --------------------------------- */
int main(int argc, char *argv[])
{
  lobdemoctx ctx;
  ub4 index;

  OCILobLocator *lob1, *lob2, *lob3, *lob4;
  OCILobLocator *bfile1, *bfile2;
  OCILobLocator *lob_arr[ARRAY_SIZE];

  initialize(&ctx);

  /* Allocate lob1, lob2 */
  (void)OCIDescriptorAlloc((void *) ctx.envhp, (void **) &lob1,
                           (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

  (void)OCIDescriptorAlloc((void *) ctx.envhp, (void **) &lob2,
                           (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

  (void)OCIDescriptorAlloc((void *) ctx.envhp, (void **) &lob3,
                           (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

  (void)OCIDescriptorAlloc((void *) ctx.envhp, (void **) &lob4,
                           (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

  for (index=0; index<ARRAY_SIZE; index++)
    (void)OCIDescriptorAlloc((void *) ctx.envhp, (void **) &lob_arr[index],
                             (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

  printf("----------------------- Test Persistent LOB Demos -----------------------------\n");
  /* --------------- Test persistent LOB Demos ------------*/
  /* Select out persistent locators */
  select_lob_for_read(lob1, ctx.errhp, ctx.svchp, ctx.stmthp, 3060, 11001);
  select_lob_for_update(lob2, ctx.errhp, ctx.svchp, ctx.stmthp, 2056, 12001);
  select_lob_array_for_update(lob_arr, ctx.errhp, ctx.svchp, ctx.stmthp);

  /* Perform all operations */
  call_lob_apis(&ctx, lob1, lob2, lob_arr);

  /* --------------- Test Temp LOB Demos ------------*/
  printf("----------------------- Test Temp LOB Demos -----------------------------\n");
  checkerr(ctx.errhp, OCILobCreateTemporary(ctx.svchp, ctx.errhp, lob3, 0, 
                                            SQLCS_IMPLICIT, OCI_TEMP_CLOB, 
                                            TRUE, OCI_DURATION_SESSION));

  checkerr(ctx.errhp, OCILobCreateTemporary(ctx.svchp, ctx.errhp, lob4, 0, 
                                            SQLCS_IMPLICIT, OCI_TEMP_CLOB, 
                                            TRUE, OCI_DURATION_SESSION));
  /* Copy over lob1 to lob3 */
  copyAllPartLOB_proc(lob1, lob3, ctx.envhp, ctx.errhp, ctx.svchp, ctx.stmthp);

  /* Perform all operations */
  call_lob_apis(&ctx, lob3, lob4, NULL);

  checkerr(ctx.errhp, OCILobFreeTemporary(ctx.svchp, ctx.errhp, lob3));
  checkerr(ctx.errhp, OCILobFreeTemporary(ctx.svchp, ctx.errhp, lob4));


  /* Free the locator descriptor */ 
  OCIDescriptorFree((void *)lob1, (ub4)OCI_DTYPE_LOB); 
  /* Free the locator descriptor */ 
  OCIDescriptorFree((void *)lob2, (ub4)OCI_DTYPE_LOB); 

  /* Free the locator descriptor */ 
  OCIDescriptorFree((void *)lob3, (ub4)OCI_DTYPE_LOB); 
  /* Free the locator descriptor */ 
  OCIDescriptorFree((void *)lob4, (ub4)OCI_DTYPE_LOB); 

  /* Free the locator descriptor array */ 
  for (index=0; index<ARRAY_SIZE; index++)
    OCIDescriptorFree((void *)lob_arr[index], (ub4)OCI_DTYPE_LOB); 

  /* --------------- Test BFILE Demos ------------*/
  /* Allocate bfile1, bfile2 */
  (void)OCIDescriptorAlloc((void *) ctx.envhp, (void **) &bfile1,
                           (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

  (void)OCIDescriptorAlloc((void *) ctx.envhp, (void **) &bfile2,
                           (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

  /* Select out persistent locators */
  select_bfile_for_read(bfile1, ctx.errhp, ctx.svchp, ctx.stmthp, 
                        ctx.envhp, 3060, 11001);
  select_bfile_for_read(bfile2, ctx.errhp, ctx.svchp, ctx.stmthp, 
                        ctx.envhp, 2056, 12001);

  bfile_demos(&ctx, bfile1, bfile2);

  /* Free the locator descriptor */ 
  OCIDescriptorFree((void *)bfile1, (ub4)OCI_DTYPE_LOB); 
  /* Free the locator descriptor */ 
  OCIDescriptorFree((void *)bfile2, (ub4)OCI_DTYPE_LOB); 


  /* clean things up before exit */
  cleanup(&ctx);

  return 1;
}
/* ---------------------------- End of main() ------------------------------ */

/* ----------------------------- call_lob_apis ----------------------------- */
void call_lob_apis(lobdemoctx *ctx, OCILobLocator *inlob, OCILobLocator *outlob,
                   OCILobLocator **lob_arr)
{
  oraub8 amt;
  /*------------------------ Calling LOB Examples ---------------------------*/
  /* OCILobRead Example */
  readLOB_proc(inlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* OCILobGetLength Example */
  getLengthLOB_proc(inlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* Lob Data Diplay Example */
  displayLOB_proc(inlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);
 
  /* OCI LOB Data Display Example */
  displayLOB_proc(inlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* OCILobCharSetID Example */
  getCsidLOB_proc(inlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);
 
  /* OCILobCharSetForm Example */
  getCsformLOB_proc(inlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* OCILobLocatorIsInit Example */
  isInitializedLOB_proc(inlob, outlob, ctx->envhp, ctx->errhp, ctx->svchp,
                        ctx->stmthp);

  /* OCILobLocatorIsEqual Example */
  locatorIsEqual_proc(inlob,outlob, ctx->envhp, ctx->errhp, ctx->svchp,
                      ctx->stmthp);

  /* OCILobIsOpen Example */
  seeIfLOBIsOpen_proc(inlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* OCI LOB Buffering Example */
  LOBBuffering_proc(outlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* LOB insert Example */
  insertLOB_proc(inlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* OCILobCopy Example */
  copyAllPartLOB_proc(inlob, outlob, ctx->envhp, ctx->errhp, ctx->svchp, 
                      ctx->stmthp);
  /* OCILobAppend Example */
  appendLOB_proc(inlob, outlob, ctx->envhp, ctx->errhp, ctx->svchp, 
                 ctx->stmthp);
  
  /* OCILobWrite Example in one-piece mode */
  amt = 100;
  writeLOB_proc(outlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp, amt);

  /* Test lob write in streaming mode */
  amt = 300;
  writeLOB_proc(outlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp, amt);

  /* OCILobWriteAppend Example */
  writeAppendLOB_proc(outlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* OCILobTrim Example */
  trimLOB_proc(outlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* OCILobErase Example */
  eraseLOB_proc(outlob, ctx->envhp, ctx->errhp, ctx->svchp, ctx->stmthp);

  /* OCILobLoadFromFile Example */  
  {
    OCILobLocator *Bfile_loc;

    printf("----------- Calling LoadFromFile2 ---------------\n");
    (void)OCIDescriptorAlloc((void *) ctx->envhp, (void **) &Bfile_loc,
                             (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

    select_bfile_for_read(Bfile_loc, ctx->errhp, ctx->svchp, ctx->stmthp, 
                          ctx->envhp, 2056, 12001);

    loadLOBDataFromBFile_proc(outlob, Bfile_loc, ctx->envhp, ctx->errhp, 
                              ctx->svchp, ctx->stmthp);

    OCIDescriptorFree((void *)Bfile_loc, (ub4)OCI_DTYPE_LOB); 
  }

  /* OCILobIsTemporary and OCILobFreeTemporary Example */
  isTempLOBAndFree_proc(outlob, ctx->envhp, ctx->errhp, ctx->svchp, 
                        ctx->stmthp);

  /* OCI LOB assignment Example */
  assignLOB_proc(inlob, outlob, ctx->envhp, ctx->errhp, ctx->svchp, 
                 ctx->stmthp);

  if (lob_arr)
  {
    /* OCI LOB Array Write Example */
    writeArrayLOB_proc(lob_arr, ctx->envhp, ctx->errhp, ctx->svchp);
 
    /* OCI LOB Array Read Example */
    readArrayLOB_proc(lob_arr, ctx->envhp, ctx->errhp, ctx->svchp);
  }
}

/* ------------------------------ bfile_demos ------------------------------ */
void bfile_demos(lobdemoctx *ctx, OCILobLocator *Bfile_loc1,
                 OCILobLocator *Bfile_loc2)
{
  /* ------------------------Calling BFILE examples -------------------------*/

  /* OCI Bfile Close  Example */
  BfileLobClose_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                     ctx->stmthp);
  /* OCILobFileClose Example */
  BfileFileClose_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                     ctx->stmthp);
  /* OCILobFileCloseAll Example */
  BfileCloseAll_proc(Bfile_loc1, Bfile_loc2, ctx->envhp, ctx->errhp, 
                     ctx->svchp, ctx->stmthp);

  /* OCI Bfile Assign Example */
  BfileAssign_proc(Bfile_loc1, Bfile_loc2, ctx->envhp, ctx->errhp, 
                   ctx->svchp, ctx->stmthp);
  /* OCI Bfile Display Example */
  BfileDisplay_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                    ctx->stmthp);
  /* OCILobFileExists Example */
  BfileExists_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                   ctx->stmthp);

  /* OCILobFileOpen Example */
  BfileFileOpen_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                     ctx->stmthp);

  /* OCILobFileIsOpen Example */
  BfileFileIsOpen_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                       ctx->stmthp);
  /* OCILobFileGetName Example */
  BfileGetDir_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                   ctx->stmthp);
  /* OCI Bfile Insert Example */
  BfileInsert_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                     ctx->stmthp);

  /* OCI Bfile IsOpen Example */
  BfileIsOpen_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                   ctx->stmthp);

  /* OCI Bfile GetLength Example */
  BfileLength_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                   ctx->stmthp);
  
  /* OCILobOpen Example */
  BfileLobOpen_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                    ctx->stmthp);
  /* OCI Bfile Read Example */
  BfileRead_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                 ctx->stmthp);
  /* OCI Bfile Update Example */
  BfileUpdate_proc(Bfile_loc1, ctx->envhp, ctx->errhp, ctx->svchp, 
                   ctx->stmthp);

}


/* Select the locator into a locator variable for update */
sb4 select_lob_for_update(OCILobLocator *Lob_loc, OCIError *errhp, 
                          OCISvcCtx *svchp, OCIStmt *stmthp,
                          int prod_id, int ad_id)
{
  OCIDefine *defnp1;
  OCIBind *bndhp1;
  OCIBind *bndhp2;

  text  *sqlstmt = 
    (text *) "SELECT ad_sourcetext \
              FROM Print_media pm \
              WHERE pm.product_id = :1 and pm.ad_id=:2 for update";

  printf("  prepare statement in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIStmtPrepare(stmthp, errhp, sqlstmt, 
                                  (ub4)strlen((char *)sqlstmt),
                                  (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT));
  printf("  OCIDefineByPos in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIDefineByPos(stmthp, &defnp1, errhp, (ub4) 1,
                                  (void *)&Lob_loc, (sb4)0, 
                                  (ub2) SQLT_CLOB,(void *) 0, 
                                  (ub2 *) 0, (ub2 *) 0, (ub4) OCI_DEFAULT));

  printf("  OCIBindByPos in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIBindByPos(stmthp, &bndhp1, errhp, (ub4) 1,
                                (void *) &prod_id, (sb4) sizeof(prod_id),
                                SQLT_INT,
                                (void *) 0, (ub2 *)0, (ub2 *)0,
                                (ub4) 0, (ub4 *) 0, (ub4) OCI_DEFAULT));

  checkerr (errhp, OCIBindByPos(stmthp, &bndhp2, errhp, (ub4) 2,
                                (void *) &ad_id, (sb4) sizeof(ad_id), SQLT_INT,
                                (void *) 0, (ub2 *)0, (ub2 *)0,
                                (ub4) 0, (ub4 *) 0, (ub4) OCI_DEFAULT));

   /* Execute the select and fetch one row */
   printf("  OCIStmtExecute in select_ad_sourcetext_locator\n");
   checkerr(errhp, OCIStmtExecute(svchp, stmthp, errhp, (ub4) 1, (ub4) 0,
                                  (CONST OCISnapshot*) 0, (OCISnapshot*) 0,  
                                  (ub4) OCI_DEFAULT));
   return 0;
}

/* Select the locator into a locator variable for read */
sb4 select_lob_for_read(OCILobLocator *Lob_loc, OCIError *errhp, 
                        OCISvcCtx *svchp, 
                        OCIStmt *stmthp, int prod_id, int ad_id)
{
  OCIDefine *defnp1;
  OCIBind *bndhp1;
  OCIBind *bndhp2;

  text  *sqlstmt = 
    (text *) "SELECT ad_sourcetext \
              FROM Print_media pm \
              WHERE pm.product_id = :1 and pm.ad_id=:2";

  printf("  prepare statement in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIStmtPrepare(stmthp, errhp, sqlstmt, 
                                  (ub4)strlen((char *)sqlstmt),
                                  (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT));
  printf("  OCIDefineByPos in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIDefineByPos(stmthp, &defnp1, errhp, (ub4) 1,
                                  (void *)&Lob_loc, (sb4)0, 
                                  (ub2) SQLT_CLOB,(void *) 0, 
                                  (ub2 *) 0, (ub2 *) 0, (ub4) OCI_DEFAULT));
  printf("  OCIBindByPos in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIBindByPos(stmthp, &bndhp1, errhp, (ub4) 1,
                                (void *) &prod_id, (sb4) sizeof(prod_id),  
                                SQLT_INT, (void *) 0, (ub2 *)0, (ub2 *)0,
                                (ub4) 0, (ub4 *) 0, (ub4) OCI_DEFAULT));

  checkerr (errhp, OCIBindByPos(stmthp, &bndhp2, errhp, (ub4) 2,
                                (void *) &ad_id, (sb4)sizeof(ad_id),  SQLT_INT,
                                (void *) 0, (ub2 *)0, (ub2 *)0,
                                (ub4) 0, (ub4 *) 0, (ub4) OCI_DEFAULT));

  /* Execute the select and fetch one row */
  printf("  OCIStmtExecute in select_ad_sourcetext_locator\n");
  checkerr(errhp, OCIStmtExecute(svchp, stmthp, errhp, (ub4) 1, (ub4) 0,
                                 (CONST OCISnapshot*) 0, (OCISnapshot*) 0,  
                                 (ub4) OCI_DEFAULT));
  return 0;
}

/* Select the locator into a locator variable for read */
sb4 select_bfile_for_read(OCILobLocator *Lob_loc, OCIError *errhp, 
                          OCISvcCtx *svchp, OCIStmt *stmthp, 
                          OCIEnv *envhp, int prod_id, int ad_id)
{
  OCIDefine *defnp1;
  OCIBind *bndhp1;
  OCIBind *bndhp2;

  text  *sqlstmt = 
    (text *) "SELECT ad_graphic \
              FROM Print_media pm \
              WHERE pm.product_id = :1 and pm.ad_id=:2";

  printf("  prepare statement in select_ad_graphic_locator\n");
  checkerr (errhp, OCIStmtPrepare(stmthp, errhp, sqlstmt, 
                                  (ub4)strlen((char *)sqlstmt),
                                  (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT));
  printf("  OCIDefineByPos in select_ad_graphic_locator\n");
  checkerr (errhp, OCIDefineByPos(stmthp, &defnp1, errhp, (ub4) 1,
                                  (void *)&Lob_loc, (sb4)0, 
                                  (ub2) SQLT_BFILE,(void *) 0,
                                  (ub2 *) 0, (ub2 *) 0, (ub4) OCI_DEFAULT));
  printf("  OCIBindByPos in select_ad_graphic_locator\n");
  checkerr (errhp, OCIBindByPos(stmthp, &bndhp1, errhp, (ub4) 1,
                                (void *) &prod_id, (sb4) sizeof(prod_id),  
                                SQLT_INT, (void *) 0, (ub2 *)0, (ub2 *)0,
                                (ub4) 0, (ub4 *) 0, (ub4) OCI_DEFAULT));

  checkerr (errhp, OCIBindByPos(stmthp, &bndhp2, errhp, (ub4) 2,
                                (void *) &ad_id, (sb4) sizeof(ad_id), SQLT_INT,
                                (void *) 0, (ub2 *)0, (ub2 *)0,
                                (ub4) 0, (ub4 *) 0, (ub4) OCI_DEFAULT));

  /* Execute the select and fetch one row */
  printf("  OCIStmtExecute in select_ad_graphic_locator\n");
  checkerr(errhp, OCIStmtExecute(svchp, stmthp, errhp, (ub4) 1, (ub4) 0,
                                 (CONST OCISnapshot*) 0, (OCISnapshot*) 0,  
                                 (ub4) OCI_DEFAULT));
  return 0;
}

/* Select lobs into a locator array for update */
sb4 select_lob_array_for_update(OCILobLocator **loc_arr, OCIError *errhp, 
                                OCISvcCtx *svchp, OCIStmt *stmthp)
{
  OCIDefine *defnp;
  OCIBind   *bndhp;

  text  *sqlstmt = 
    (text *) "SELECT ad_finaltext \
              FROM Print_media pm \
              WHERE ad_finaltext is not null \
              ORDER BY ad_id for update";

  printf("  prepare statement in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIStmtPrepare(stmthp, errhp, sqlstmt, 
                                  (ub4)strlen((char *)sqlstmt),
                                  (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT));

  printf("  OCIDefineByPos in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIDefineByPos(stmthp, &defnp, errhp, (ub4) 1,
                                  (void *)loc_arr, (sb4)(-1), 
                                  (ub2) SQLT_CLOB,(void *) 0, 
                                  (ub2 *) 0, (ub2 *) 0, (ub4) OCI_DEFAULT));

/*
  printf("  OCIBindByPos in select_ad_sourcetext_locator\n");
  checkerr (errhp, OCIBindByPos(stmthp, &bndhp, errhp, (ub4) 1,
                                (void *) &ad_id, (sb4) sizeof(ad_id),
                                SQLT_INT,
                                (void *) 0, (ub2 *)0, (ub2 *)0,
                                (ub4) 0, (ub4 *) 0, (ub4) OCI_DEFAULT));
*/

   /* Execute the select and fetch rows */
   printf("  OCIStmtExecute in select_ad_sourcetext_locator\n");
   checkerr(errhp, OCIStmtExecute(svchp, stmthp, errhp, (ub4)ARRAY_SIZE,
                                  (ub4) 0, (CONST OCISnapshot*) 0,
                                  (OCISnapshot*) 0,  (ub4) OCI_DEFAULT));
   return 0;
}

/*initialize envionment and handler*/
void initialize(lobdemoctx *ctxptr)
{

  if (OCIEnvCreate((OCIEnv **) &ctxptr->envhp,
                   (ub4)OCI_THREADED|OCI_OBJECT, (void *)0,
                    (void * (*)(void *, size_t)) 0,
                   (void * (*)(void *, void *, size_t))0,
                   (void (*)(void *, void *)) 0,
                   (size_t) 0, (void **) 0 ))
    printf("FAILED: OCIEnvCreate()\n");


  printf("\n ######## Connect to server ############# \n");

  if (OCIHandleAlloc((void *) ctxptr->envhp,
                     (void **) &ctxptr->errhp,
                     (ub4) OCI_HTYPE_ERROR, (size_t) 0, (void **) 0))
    printf("FAILED: OCIHandleAlloc() on ctxptr->errhp\n");

  if (OCIHandleAlloc((void *) ctxptr->envhp,
                     (void **) &ctxptr->srvhp,
                     (ub4) OCI_HTYPE_SERVER, (size_t) 0, (void **) 0))
    printf("FAILED: OCIHandleAlloc() on ctxptr->srvhp\n");

  if (OCIHandleAlloc((void *) ctxptr->envhp,
                     (void **) &ctxptr->svchp,
                     (ub4) OCI_HTYPE_SVCCTX, (size_t) 0, (void **) 0))
    printf("FAILED: OCIHandleAlloc() on ctxptr->svchp\n");

  if (OCIHandleAlloc((void *) ctxptr->envhp,
                     (void **) &ctxptr->authp,
                     (ub4) OCI_HTYPE_SESSION, (size_t) 0, (void **) 0))
    printf("FAILED: OCIHandleAlloc() on ctxptr->authp\n");

  if (OCIServerAttach(ctxptr->srvhp, ctxptr->errhp,
                      (text *) "", (sb4) strlen((char *) ""),
                      (ub4) OCI_DEFAULT))
    printf("FAILED: OCIServerAttach()\n");

  if (OCIAttrSet((void *) ctxptr->svchp, (ub4) OCI_HTYPE_SVCCTX,
                 (void *) ctxptr->srvhp, (ub4) 0,
                 (ub4) OCI_ATTR_SERVER, ctxptr->errhp))
    printf("FAILED: OCIAttrSet() server attribute\n");
  
  /*begin log_on part */
  if (OCIAttrSet((void *) ctxptr->authp, (ub4) OCI_HTYPE_SESSION,
                 (void *) username, (ub4) strlen((char *) username),
                 (ub4) OCI_ATTR_USERNAME, ctxptr->errhp))
    printf("FAILED: OCIAttrSet() userid\n");

  if (OCIAttrSet((void *) ctxptr->authp, (ub4) OCI_HTYPE_SESSION,
                 (void *) password, (ub4) strlen((char *) password),
                 (ub4) OCI_ATTR_PASSWORD, ctxptr->errhp))
    printf("FAILED: OCIAttrSet() passwd\n");
      
  printf("Logging on as %s  ....\n", username);
  
  checkerr(ctxptr->errhp, OCISessionBegin((void *)ctxptr->svchp,
                        ctxptr->errhp, ctxptr->authp,
                       (ub4) OCI_CRED_RDBMS,(ub4) OCI_DEFAULT ));
    
  printf("%s logged on.\n", username);
                 
  if (OCIAttrSet((void *) ctxptr->svchp, (ub4) OCI_HTYPE_SVCCTX,
             (void *) ctxptr->authp, (ub4) 0, (ub4) OCI_ATTR_SESSION, 
             ctxptr->errhp))
    printf("FAILED: OCIAttrSet() session\n");
  /* end log_on part */

  /* alocate stmt handle for sql queries */
  
  if (OCIHandleAlloc((void *)ctxptr->envhp, (void **) &ctxptr->stmthp,
                   (ub4)OCI_HTYPE_STMT, (CONST size_t) 0, (void **) 0))
    printf("FAILED: alloc statement handle\n");

} /* end initialize() */


void cleanup(lobdemoctx *ctxptr)
{
  printf("\n ########## clean up ############ \n");

  if (OCISessionEnd(ctxptr->svchp, ctxptr->errhp, 
                      ctxptr->authp, (ub4) 0))
    printf("FAILED: OCISessionEnd()\n");

  printf("%s Logged off.\n", username);

  if (OCIServerDetach(ctxptr->srvhp, ctxptr->errhp,
                   (ub4) OCI_DEFAULT))
    printf("FAILED: OCIServerDetach()\n");

  printf("Detached from server.\n");
  
  printf("Freeing handles ...\n");
  if (ctxptr->stmthp)
    OCIHandleFree((void *) ctxptr->stmthp, (ub4) OCI_HTYPE_STMT);
  if (ctxptr->errhp)
    OCIHandleFree((void *) ctxptr->errhp, (ub4) OCI_HTYPE_ERROR);   
  if (ctxptr->srvhp)
    OCIHandleFree((void *) ctxptr->srvhp, (ub4) OCI_HTYPE_SERVER);
  if (ctxptr->svchp)
    OCIHandleFree((void *) ctxptr->svchp, (ub4) OCI_HTYPE_SVCCTX);
  if (ctxptr->authp)
    OCIHandleFree((void *) ctxptr->authp, (ub4) OCI_HTYPE_SESSION);
  if (ctxptr->envhp)
    OCIHandleFree((void *) ctxptr->envhp, (ub4) OCI_HTYPE_ENV);

} /* end cleanup() */

/*check status and print error information*/
void checkerr(OCIError *errhp, sword status)
{
  text errbuf[512];
  sb4 errcode = 0;

  switch (status)
  {
  case OCI_SUCCESS:
    break;
  case OCI_SUCCESS_WITH_INFO:
    (void) printf("Error - OCI_SUCCESS_WITH_INFO\n");
    break;
  case OCI_NEED_DATA:
    (void) printf("Error - OCI_NEED_DATA\n");
    break;
  case OCI_NO_DATA:
    (void) printf("Error - OCI_NODATA\n");
    break;
  case OCI_ERROR:
    (void) OCIErrorGet((void *)errhp, (ub4) 1, (text *) NULL, &errcode,
                        errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
    (void) printf("Error - %.*s\n", 512, errbuf);
    break;
  case OCI_INVALID_HANDLE:
    (void) printf("Error - OCI_INVALID_HANDLE\n");
    break;
  case OCI_STILL_EXECUTING:
    (void) printf("Error - OCI_STILL_EXECUTE\n");
    break;
  case OCI_CONTINUE:
    (void) printf("Error - OCI_CONTINUE\n");
    break;
  default:
    break;
  }
} /* end checkerr() */
