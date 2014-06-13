/* This is installed in the following path when you install */
/* the database: $ORACLE_HOME/rdbms/demo/lobs/oci/lequal.c */

/* Seeing if One LOB locator is Equal to Another */
#include <oratypes.h>
#include "lobdemo.h"
void locatorIsEqual_proc(OCILobLocator *Lob_loc1, OCILobLocator *Lob_loc2,
                         OCIEnv *envhp, OCIError *errhp, OCISvcCtx *svchp, 
                         OCIStmt *stmthp)
{
  boolean       isEqual;
  OCILobLocator *Lob_loc3;
  
  printf ("----------- OCILobIsEqual Demo --------------\n");


  /* Call OCI to see if the two locators are Equal: */
  printf (" check if Lob1 and Lob2 are Equal.\n");
  checkerr (errhp, OCILobIsEqual(envhp, Lob_loc1, Lob_loc2, &isEqual));

  if (isEqual)
  {
    /* ... The LOB locators are Equal: */
    printf(" Lob Locators are equal.\n");
  }
  else
  {
    /* ... The LOB locators are not Equal: */
    printf(" Lob Locators are NOT Equal.\n");
  }

  (void)OCIDescriptorAlloc((void *) envhp, (void **) &Lob_loc3,
                             (ub4)OCI_DTYPE_LOB, (size_t) 0, (void **) 0);

  /* Assign Lob_loc1 to Lob_loc2 thereby saving a copy of the value of the LOB
     at this point in time: */
  printf(" assign the src locator to dest locator\n");
  checkerr (errhp, OCILobLocatorAssign(svchp, errhp, Lob_loc1, &Lob_loc3)); 

  /* When you write some data to the LOB through Lob_loc1, Lob_loc2 will not
     see the newly written data whereas Lob_loc1 will see the new data: */

  /* Call OCI to see if the two locators are Equal: */
  printf (" check if Lob1 and Lob3 are Equal.\n");
  checkerr (errhp, OCILobIsEqual(envhp, Lob_loc1, Lob_loc3, &isEqual));

  if (isEqual)
  {
    /* ... The LOB locators are Equal: */
    printf(" Lob Locators are equal.\n");
  }
  else
  {
    /* ... The LOB locators are not Equal: */
    printf(" Lob Locators are NOT Equal.\n");
  }

  OCIDescriptorFree((void *)Lob_loc3, (ub4)OCI_DTYPE_LOB); 
  
  return;
}
