/* Copyright (c) 2007, Oracle. All rights reserved.  */

/*

   NAME
     LocatorAPI_Insert.c - Lob demo using Locator Interface for Inserts

   DESCRIPTION

   EXPORT FUNCTION(S)

   INTERNAL FUNCTION(S)

   STATIC FUNCTION(S)

   NOTES

   MODIFIED   (MM/DD/YY)
   vdjegara    04/05/07 - Call PrepareDbTime() before calling GetDbTime()
   vdjegara    01/29/07 - Locator Interface Insert test
   vdjegara    01/29/07 - Creation

*/

#include <oratypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <sys/time.h> 
#include "LobUtilFunc.h"


/* We do NOT free any memory but exit when problems occur !!! */


int main(int argc, char *argv[])
{
  ub1 *LobWriteBuf=NULL;
  ub4 *KeysWriteBuf=NULL;
  OCIStmt *stmtinserthp = 0;
  OCIStmt *stmtsellochp = 0;
  OCIBind *bndv1 = 0;
  OCIBind *bndv2 = 0;
  OCIDefine *defv1 = 0;
  OCILobLocator *lobloc=0;
  static text *stmt_insertstr = (text *)"INSERT INTO FOO VALUES (:PKEY, EMPTY_BLOB() )";
  static text *stmt_sellocstr = (text *)"SELECT DOCUMENT FROM FOO WHERE PKEY = :MYPKEY FOR UPDATE";

  int i, j, q;                  /* loop variables */
  sword orc;
  ub4 LobSize = 0;              /* Size of Lob to be inserted */
  ub4 Iter=1;                   /* How many times to repeat before exiting */
  ub4 NumRows=0;                /* Num of Rows to insert in each iteration, also used for commit batch size */
  ub4 trace_flag=0;             /* 0 is default, means no sql_trace */ 
  ub4 NextKeyStart=0;           /* used if Iter > 1 */ 
  int UserNum=1;                /* used in multiuser tests */
  ub4 KeyStartValue=0;          /* used as primary key generator */ 
  ub4 KeyValue=0;               /* used as temporary Key value */
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
    printf("Usage: %s <uid> <pwd> <LobSize(bytes)> <NumRows or CommitSize> <Iteration> <UserNum> trace_flag(1|0>\n\r", argv[0]);
    exit(-1);
  }

  /* process command line args */
  LobSize=atoi(argv[3]);
  NumRows=atoi(argv[4]);
  Iter=atoi(argv[5]);

  if (argc > 6 )
    UserNum=atoi(argv[6]);                /* Used in multiuser run, to make unique pkeys */

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

  printf("Using LobSize=%d bytes, NumRows=%d, calculated total memorysize=%d bytes\r\n", LobSize, NumRows, LobSize*NumRows);

  if((LobSize==0)||(NumRows<1))
  {
   printf("Parameter error\r\n");
   exit(-1);
  }

  /* Memory allocation section */
  if ( (LobWriteBuf=(ub1 *)malloc(LobSize)) == NULL ) {
    printf("Error allocating memory for LobWriteBuf\r\n");
    exit(-1);
  }

  if ( (KeysWriteBuf=(ub4 *)malloc(NumRows*sizeof(ub4))) == NULL ) {
    printf("Error allocating memory for KeysWriteBuf\r\n");
    exit(-1);
  }


  /* Initialize allocated memory and setup data to be inserted */
  memset(LobWriteBuf,90,LobSize);               /* setup Lob write data as 5A */

  KeyStartValue=UserNum*USERKEYRANGE;           /* Value is set as per UserNum */
  for(i=0;i<NumRows;i++)
  {
    KeysWriteBuf[i]=i+KeyStartValue;            /* setup pkeys as 100000, 100001, 100002..UserkeyRange+NumRows */
  }

  /* SQL_TRACE section */
  if (trace_flag == 1) { 
    printf("Begin tracing...\n");
    TurnOnSqlTrace();
  }  
 
  printf("Trying to insert %d Rows with Lob size of %d Bytes)\r\n", NumRows, LobSize);
  printf("Inserting data.....please wait\r\n");

  /* allocate a statement handle for INSERT WITH EMPTY_LOB and prepare it */
  CheckErr(errhp, OCIHandleAlloc(envhp, (dvoid **) &stmtinserthp, OCI_HTYPE_STMT,
                  (size_t) 0, (dvoid **) 0));

  CheckErr(errhp, OCIStmtPrepare(stmtinserthp, errhp, (CONST text *) stmt_insertstr,
                  strlen((char *) stmt_insertstr), OCI_NTV_SYNTAX, OCI_DEFAULT));
  
  /* allocate a statement handle for SELECT OF LOB LOCATOR  and prepare it */
  CheckErr(errhp, OCIHandleAlloc(envhp, (dvoid **) &stmtsellochp, OCI_HTYPE_STMT,
                  (size_t) 0, (dvoid **) 0));
 
  CheckErr(errhp, OCIStmtPrepare(stmtsellochp, errhp, (CONST text *) stmt_sellocstr,
                  strlen((char *) stmt_sellocstr), OCI_NTV_SYNTAX, OCI_DEFAULT));
 
  /* Allocate Lob Locator descriptor */ 
  CheckErr(errhp, OCIDescriptorAlloc(envhp, (dvoid **)&lobloc, (ub4) OCI_DTYPE_LOB, (size_t) 0, (dvoid **) 0)) ;

  CheckErr(errhp, OCIBindByName(stmtinserthp, (OCIBind **) &bndv1, errhp,
                  (text *)":PKEY", (sb4) 5, &KeyValue, (sb4) sizeof(ub4), SQLT_INT,
                  (dvoid *) 0, (ub2 *) 0, (ub2 *) 0, (ub4) 0, (ub4 *) 0, OCI_DEFAULT));

   /* Now select Lob locator for the inserted row */
  CheckErr(errhp, OCIBindByName(stmtsellochp, (OCIBind **) &bndv2, errhp,
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
         KeyValue=KeysWriteBuf[i];

         /* Insert into foo values (pkey, empty_blob() );  */
         CheckErr(errhp, OCIStmtExecute(svchp, stmtinserthp, errhp, (ub4) 1, (ub4) 0,
                         (CONST OCISnapshot *) 0, (OCISnapshot *) 0, OCI_DEFAULT));

         /* Select statement to get Locator */
         CheckErr(errhp, OCIStmtExecute(svchp, stmtsellochp, errhp, (ub4) 1, (ub4) 0,
                         (CONST OCISnapshot *) 0, (OCISnapshot *) 0, OCI_DEFAULT));

         /* Got the Locator, now start writing data using it */
         CheckErr(errhp, OCILobWrite(svchp, errhp, lobloc, &LobSize, 
                         1, &LobWriteBuf[0], (ub4) LobSize, OCI_ONE_PIECE,
                         (dvoid *)0, NULL, (ub2) 0, (ub1) SQLCS_IMPLICIT));

     }
     /* Not an proper Array Insert, but we commit after CommitSize or NumRows to avoid single row inserts */
     CheckErr(errhp, OCITransCommit(svchp, errhp, (ub4) OCI_DEFAULT));

     EndTime = GetDbTime(1);
     ElapsedTime = (EndTime - StartTime)*10 ;

     printf("Elapsed time for Iter %d Inserted (%d rows) in msecs: %ld\n", q+1, NumRows, ElapsedTime);


     /* for more than 1 Iter, refill KeysWriteBuf array, to avoid duplicates */
     if (Iter > 1 ) {
        NextKeyStart=KeyStartValue+(NumRows*(q+1));            /* since q start with 0, add 1 */
        for (i=0; i< NumRows; i++ ) {
           KeysWriteBuf[i]=NextKeyStart+i;
        }
     }
  }     /* end of Iteration 'for' loop */

  EndTimeTot = EndTime;
  ElapsedTimeTot = (EndTimeTot-StartTimeTot)*10;

  EndCpu = GetDbTime(0);
  /* cpu time is centisecond, x10 to report in msec, not accurate, doing it for consistency */
  ElapsedCpu = (EndCpu - StartCpu) * 10;

  printf ("--------------------------------------------------------------------------- \n");
  printf("Total Elapsed time for Insert (%d rows) in msecs (excluding Iter 1) : %ld\n", NumRows*(Iter-1), ElapsedTimeTot);
  

  if (Iter > 1) {
    AvgElapsed=ElapsedTimeTot/(Iter-1);
    AvgCpu=ElapsedCpu/(Iter-1);
    printf("Avg Elapsed time for a Iteration (%d rows) in msecs (excluding Iter 1) : %ld\n", NumRows, AvgElapsed );
    printf("Avg CPU time for a Iteration  (%d rows) in msecs (excluding Iter 1) : %ld\n", NumRows, AvgCpu );

    /* x1000 to report in seconds from mseconds */
    AvgRate=((float)LobSize*(float)NumRows*1000)/((float)AvgElapsed*1024*1024);
    printf("Avg Write Rate for (%d rows) (excluding Iter 1) : %0.2f (Mb/sec)\n", NumRows,  AvgRate);
  }

  LobType=CheckLobType();

  if (LobType == 1) 
    printf ("SECUREFILE Lob Write Test Finished (Using OCILobWrite API)\n");
  else
    printf ("BASICFILE Lob Write Test Finished (Using OCILobWrite API)\n");
  
  printf("Inserted LobSize=%d bytes, NumRows or CommitSize=%d, Iter=%d \r\n", LobSize, NumRows, Iter );
  printf ("--------------------------------------------------------------------------- \n");

  return(0);
 
} /* end of Main */


/* end of file LocatorAPI_Insert.c */

