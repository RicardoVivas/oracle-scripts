/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/flength.c */

/* Getting the length of a BFILE.  */
/* Select the lob/bfile from table Print_media */ 
#include <oratypes.h>
#include "lobdemo.h"
void BfileLength_proc(OCILobLocator *Bfile_loc, OCIEnv *envhp,
                      OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{ 
   oraub8 len;
 
   printf ("----------- OCILobGetLength BFILE Demo --------------\n");
   checkerr (errhp, OCILobFileOpen(svchp, errhp, Bfile_loc,
                                   (ub1) OCI_FILE_READONLY));

   checkerr (errhp, OCILobGetLength2(svchp, errhp, Bfile_loc, &len));

   printf("Length of bfile = %d\n", (ub4)len);
 
   checkerr (errhp, OCILobFileClose(svchp, errhp, Bfile_loc));
}
