#include <oratypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <oci.h>

#define MAXBUFLEN 20
#define ARRAY_SIZE 4 

void checkerr(OCIError *errhp, sword status);

/* OCILobRead Example */
void readLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp, 
                  OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobWrite Example */
void writeLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp, 
                   OCISvcCtx *svchp, OCIStmt *stmt, oraub8 amt_to_write);

/* OCILobGetLength Example */
void getLengthLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp, 
                       OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCI LOB Buffering Example */
void LOBBuffering_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp,
                       OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobCopy Example */
void copyAllPartLOB_proc(OCILobLocator *Lob_loc1, OCILobLocator *Lob_loc2, 
                         OCIEnv *envhp, OCIError *errhp,
                         OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILOBAssign Example */
void assignLOB_proc(OCILobLocator *Lob_loc1, OCILobLocator *Lob_loc2, 
                    OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCI LOB Data Display Example */
void displayLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp,
                     OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobCharSetID Example */
void getCsidLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp,
                     OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobCharSetForm Example */
void getCsformLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp,
                       OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobLocatorIsInit Example */
void isInitializedLOB_proc(OCILobLocator *Lob_loc1, OCILobLocator *Lob_loc2, 
                           OCIEnv *envhp, OCIError *errhp,
                           OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobLocatorIsEqual Example */
void locatorIsEqual_proc(OCILobLocator *Lob_loc1, OCILobLocator *Lob_loc2,
                         OCIEnv *envhp, OCIError *errhp, OCISvcCtx *svchp, 
                         OCIStmt *stmthp);

/* OCILobAppend Example */
void appendLOB_proc(OCILobLocator *Lob_loc1,OCILobLocator *Lob_loc2, 
                    OCIEnv *envhp, OCIError *errhp, OCISvcCtx *svchp, 
                    OCIStmt *stmthp);

/* OCILobErase Example */
void eraseLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp, 
                   OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobIsOpen Example */
void seeIfLOBIsOpen_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp,
                         OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobIsTemporary and OCILobFreeTemporary Example */
void isTempLOBAndFree_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp, 
                           OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobLoadFromFile Example */
void loadLOBDataFromBFile_proc(OCILobLocator *Lob_loc, OCILobLocator *BFile_loc, 
                               OCIEnv *envhp, OCIError *errhp, 
                               OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobTrim Example */
void trimLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp, 
                  OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCILobWriteAppend Example */
void writeAppendLOB_proc(OCILobLocator *Lob_loc1,
                         OCIEnv *envhp, OCIError *errhp, 
                         OCISvcCtx *svchp, OCIStmt *stmthp);

/* OCI LOB Insert Example */
void insertLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);


/* OCI Bfile Close  Example */
void BfileLobClose_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCILobFileClose Example */
void BfileFileClose_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCILobFileCloseAll Example */
void BfileCloseAll_proc(OCILobLocator *Bfile_loc1, OCILobLocator *Bfile_loc2, 
                        OCIEnv *envhp, OCIError *errhp, 
                        OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCI Bfile Assign Example */
void BfileAssign_proc(OCILobLocator *Bfile_loc1, OCILobLocator *Bfile_loc2, 
                      OCIEnv *envhp, OCIError *errhp, 
                      OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCI Bfile Display Example */
void BfileDisplay_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCILobFileExists Example */
void BfileExists_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCILobFileOpen Example */
void BfileFileOpen_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCILobFileIsOpen Example */
void BfileFileIsOpen_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCILobFileGetName Example */
void BfileGetDir_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCI Bfile Insert Example */
void BfileInsert_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCI Bfile IsOpen Example */
void BfileIsOpen_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCI Bfile GetLength Example */
void BfileLength_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCILobOpen Example */
void BfileLobOpen_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCI Bfile Read Example */
void BfileRead_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCI Bfile Update Example */
void BfileUpdate_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp, OCIError *errhp, 
                    OCISvcCtx *svchp, OCIStmt *stmthp);
/* OCI Lob Array Read Example */
void readArrayLOB_proc(OCILobLocator **loc_arr, OCIEnv *envhp,
                       OCIError *errhp, OCISvcCtx *svchp);
/* OCI Lob Array Write Example */
void writeArrayLOB_proc(OCILobLocator **loc_arr, OCIEnv *envhp,
                        OCIError *errhp, OCISvcCtx *svchp);
/* Main routine */
int main(int argc, char *argv[]);
