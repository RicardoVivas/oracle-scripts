/* This file is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lgetchfm.c */

/* Getting character set form of the foreign language ad text, ad_fltextn */
#include <oratypes.h>
#include "lobdemo.h"
/* This function takes a valid LOB locator and prints the character set form
   of the LOB. 
 */
void getCsformLOB_proc(OCILobLocator *Lob_loc, OCIEnv *envhp,
                       OCIError *errhp, OCISvcCtx *svchp, OCIStmt *stmthp)
{
  ub1 charset_form = 0 ;
  printf ("----------- OCILobCharSetForm Demo --------------\n"); 

  printf (" get the character set form of ad_fltextn\n");
  /* Get the charactersid form of the LOB*/
  checkerr (errhp, OCILobCharSetForm(envhp, errhp, Lob_loc, &charset_form));
  printf(" character Set Form of ad_fltextn is : %d\n", charset_form);
  
  return;
}
