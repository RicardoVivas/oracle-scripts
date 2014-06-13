/* Copyright (c) 2007, Oracle. All rights reserved.  */

/*

   NAME
     LocatorAPI_Select.c - Lob demo using Locator Interface for Selects

   DESCRIPTION

   EXPORT FUNCTION(S)

   INTERNAL FUNCTION(S)

   STATIC FUNCTION(S)

   NOTES

   MODIFIED   (MM/DD/YY)
   vdjegara    04/05/07 - Call PrepareDbTime() before calling GetDbTime()
   vdjegara    01/29/07 - Locator Interface Select test
   vdjegara    01/29/07 - Creation

*/

#include <oratypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <sys/time.h> 
#include "LobUtilFunc.h"


/* we do NOT free any memory but exit when problems occur !!! */


int main(int argc, char *argv[])
{

  ub1 *LobReadBuf=NULL;
  ub4 *KeysValueBuf=NULL;
  OCIStmt *stmtsellochp = 0;
  OCIBind *bndv1 = 0;
  OCIDefine *defv1 = 0;
  OCILobLocator *lobloc=0;
  static text *stmt_sellocstr = (text *)"SELECT DOCUMENT FROM FOO WHERE PKEY = :MYPKEY";

  int i, j, q;                  /* loop variables */
  sword orc;                    /* Return value */
  ub4 LobSize = 0;              /* Size of Lob to be selected */
  ub4 Iter=1;                   /* How many times to repeat before exiting */
  ub4 NumRows=0;                /* Num of Rows to select in each iteration */
  ub4 trace_flag=0;             /* 0 is default, means no sql_trace */
  int UserNum=1;                /* used in multiuser tests */

  ub4 KeyStartValue=0;          /* primary key generator, derived from USERKEYRANGE * UserNum */
  ub4 KeyMaxValue=0;            /* derived from StartValue + NumRows*Iter */
  sb8 KeyValue=0;               /* random number between StartValue and MaxValue */
  int LobType;                  /* to check Lobtype = BASICFILE or SECUREFILE */
  int ReqTime;                  /* argument to GetDbTime function ReqTime=1 elasped, ReqTime=0 cpu time */

  ub4 StartTimeTot;
  ub4 StartTime;
  ub4 StartCpu;

  ub4 EndTimeTot;
  ub4 EndTime;
  ub4 EndCpu;

  ub4 ElapsedTimeTot;
  ub4 ElapsedTime;
  ub4 ElapsedCpu;

  ub4 AvgElapsed;
  ub4 AvgCpu;
  float AvgRate;



  if (argc <= 5) {
    printf("Usage: %s <uid> <pwd> <LobSize(bytes)> <NumRows> <Iteration> <UserNum> trace_flag(1|0>\n\r", argv[0]);
    exit(-1);
  }

  /* process command line args */
  LobSize=atoi(argv[3]);
  NumRows=atoi(argv[4]);
  Iter=atoi(argv[5]);

  if (argc > 6 )
    UserNum=atoi(argv[6]);                  /* Used in multiuser run, to make unique pkeys */

  if (argc > 7 )
    trace_flag=atoi(argv[7]);

  /* Allocate OCI handles */
  if (AllocateHandles(0)) {
    printf("AllocateHandles failed \n");
    exit(-1);
  }

  /* Login using argv[1] and argv[2] */
  if ( (ConnectToDb(argv[1], argv[2])) != OCI_SUCCESS ) { 
    printf("ConnectToDb failed \n");
    CheckErr(errhp, orc);
    exit(-1);
  }

  srand48(LobSize);

  printf("Using LobSize=%d bytes, NumRows=%d, calculated total memorysize=%d bytes\r\n", LobSize, NumRows, LobSize*NumRows);

  if((LobSize==0)||(NumRows<1))
  {
   printf("Parameter error\r\n");
   exit(-1);
  }

  /* Memory allocation section */
  if ( (LobReadBuf=(ub1 *)malloc(LobSize)) == NULL ) {
    printf("Error allocating memory for LobReadBuf\r\n");
    exit(-1);
  }

  /* Initialize allocated memory and setup Read buffer as 0000000 */
  memset(LobReadBuf,0,LobSize);                 /* setup Lob read buffer as 0 */

  KeyStartValue=UserNum*USERKEYRANGE;           /* Value is set as per UserNum */
  KeyMaxValue = KeyStartValue + (NumRows*Iter);


  /* SQL_TRACE section */
  if (trace_flag == 1) { 
    printf("Begin tracing...\n");
    TurnOnSqlTrace();
  }  
 
  printf("Trying to Select %d Rows with Lob size of %d Bytes)\r\n", NumRows, LobSize);
  printf("Selecting data.....please wait\r\n");

  /* allocate a statement handle for SELECT OF LOB LOCATOR  and prepare it */
  CheckErr(errhp, OCIHandleAlloc(envhp, (dvoid **) &stmtsellochp, OCI_HTYPE_STMT,
                                     (size_t) 0, (dvoid **) 0));
 
  CheckErr(errhp, OCIStmtPrepare(stmtsellochp, errhp, (CONST text *) stmt_sellocstr,
                                     strlen((char *) stmt_sellocstr), OCI_NTV_SYNTAX, OCI_DEFAULT));
 
  /* Allocate Lob Locator descriptor */ 
  CheckErr(errhp, OCIDescriptorAlloc(envhp, (dvoid **)&lobloc, (ub4) OCI_DTYPE_LOB, (size_t) 0, (dvoid **) 0)) ;
  
  CheckErr(errhp, OCIBindByName(stmtsellochp, (OCIBind **) &bndv1, errhp,
                  (text *)":MYPKEY", (sb4) 7, &KeyValue, (sb4) sizeof(ub4), SQLT_INT,
                  (dvoid *) 0, (ub2 *) 0, (ub2 *) 0, (ub4) 0, (ub4 *) 0, OCI_DEFAULT));

  CheckErr(errhp, OCIDefineByPos (stmtsellochp, (OCIDefine **) &defv1, errhp,
                  1, &lobloc, 0 , SQLT_BLOB,
                  (dvoid *)0, (ub2 *)0, (ub2 *)0, OCI_DEFAULT));

  /* Allocate and Prepare statement to get cpu and elapsed time using dbms_utility */
  PrepareDbTime();

  for (q = 0 ; q < Iter ; q ++ ) { 
     
     StartTime = GetDbTime(1);

     if ( q == 1)  {                       /* Discard q=0 as warm up */
       StartTimeTot = StartTime;
       StartCpu = GetDbTime(0);
     }

     for (i=0; i < NumRows; i++) {

         KeyValue=(lrand48 () % (KeyMaxValue-KeyStartValue)) + KeyStartValue ;

         CheckErr(errhp, OCIStmtExecute(svchp, stmtsellochp, errhp, (ub4) 1, (ub4) 0,
                         (CONST OCISnapshot *) 0, (OCISnapshot *) 0, OCI_DEFAULT));

         /*
         CheckErr(errhp, OCILobGetLength(svchp, errhp, lobloc, &LobReadLen));
         printf ("Length of the lob to read %d \n", LobReadLen);
         */

         /* Got the Locator, now start Reading data using it */
         CheckErr(errhp, OCILobRead(svchp, errhp, lobloc, &LobSize, 
                         1, &LobReadBuf[0], (ub4) LobSize, 
                         (dvoid *)0, NULL, (ub2) 0, (ub1) SQLCS_IMPLICIT));

     }

     EndTime = GetDbTime(1);

     ElapsedTime = (EndTime - StartTime)*10 ;

     printf("Elapsed time for Iter %d Select (%d rows) in msecs: %ld\n", q+1, NumRows, ElapsedTime);

  }    /* end of Iteration 'for' loop */

  EndTimeTot = EndTime;
  ElapsedTimeTot = (EndTimeTot-StartTimeTot)*10;
  
  EndCpu = GetDbTime(0);
  /* cpu time is centisecond, x10 to report in msec, not accurate, doing it for consistency */
  ElapsedCpu = (EndCpu - StartCpu) * 10;

  printf ("--------------------------------------------------------------------------- \n");
  printf("Total Elapsed time for select (%d rows) in msecs (excluding Iter 1) : %ld\n", (NumRows*(Iter-1)), ElapsedTimeTot);

  if (Iter > 1) {
    AvgElapsed=ElapsedTimeTot/(Iter-1);
    AvgCpu=ElapsedCpu/(Iter-1);
    printf("Avg Elapsed time for a Iteration (%d rows) in msecs (excluding Iter 1) : %ld\n", NumRows, AvgElapsed );
    printf("Avg CPU time for a Iteration  (%d rows) in msecs (excluding Iter 1) : %ld\n", NumRows, AvgCpu );

    /* x1000 to report in seconds from mseconds */
    AvgRate=((float)LobSize*(float)NumRows*1000)/((float)AvgElapsed*1024*1024);
    printf("Avg Read Rate for (%d rows) (excluding Iter 1) : %0.2f (Mb/sec)\n", NumRows,  AvgRate);
  }

  LobType=CheckLobType();

  if (LobType == 1)
    printf ("SECUREFILE Lob Read Test Finished (Using OCILobRead API)\n");
  else
    printf ("BASICFILE Lob Read Test Finished (Using OCILobRead API)\n");
 
  printf("Selected LobSize=%d bytes, NumRows=%d, Iter=%d \r\n", LobSize, NumRows, Iter );
  printf ("--------------------------------------------------------------------------- \n");
 
  return(0);
  
}  /* end of Main */


/* end of file LocatorAPI_Select.c */

