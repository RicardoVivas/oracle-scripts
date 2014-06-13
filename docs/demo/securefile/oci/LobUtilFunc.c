/* Copyright (c) 2007, Oracle. All rights reserved.  */

/*

   NAME
     LobUtilFunc.c -  Lob demo login, handle allocation, trace, errcheck functions

   DESCRIPTION
     Mostly all utility functions like login, OCI handle allocation, errchecking,
     and sqltrace, cpu time etc

   EXPORT FUNCTION(S)

   INTERNAL FUNCTION(S)

   STATIC FUNCTION(S)

   NOTES

   MODIFIED   (MM/DD/YY)
   vdjegara    04/05/07 - Fix GetDbTime to avoid repeated prepare and bind.
                          PrepareDbTime is added
   vdjegara    01/29/07 - All common functions
   vdjegara    01/29/07 - Creation

*/

#include <oratypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "LobUtilFunc.h"

# ifndef externref
#  define externref 
# endif


externref OCIEnv     *envhp ;
externref OCIError   *errhp ;
externref OCISvcCtx  *svchp ;
externref OCIServer  *srvhp ;
externref OCISession *authp ;

externref OCIStmt *stmt_cputimehp;
externref OCIStmt *stmt_elptimehp;
externref ub4 cpu_time_value;
externref ub4 elp_time_value;
 
sword AllocateHandles(ub1 mymem)
{

    if (OCIEnvCreate(&envhp,
                         (ub4) OCI_DEFAULT,
                         (dvoid *)0,
                         (dvoid * (*)(dvoid *, size_t)) 0,
                         (dvoid * (*)(dvoid *, dvoid *, size_t))0,
                         (void (*)(dvoid *, dvoid *)) 0,
                         0,
                         (dvoid **) 0) != OCI_SUCCESS) {
            return OCI_ERROR;
    }
 
    /* allocate an error handle withtin the environment */
    if (OCIHandleAlloc((dvoid *) envhp, (dvoid **) &errhp,
                       (ub4) OCI_HTYPE_ERROR, (size_t) 0, (dvoid **) 0)) {
        printf("OCIHandleAlloc failed for errhp\n");
        return OCI_ERROR;
    }
    
    /* allocate a service context handle within the environment */
    if (OCIHandleAlloc((dvoid *) envhp, (dvoid **) &svchp ,
                       (ub4) OCI_HTYPE_SVCCTX, (size_t) 0, (dvoid **) 0)) {
        printf("OCIHandleAlloc failed for context\n");
        return OCI_ERROR;
    }
    
    return OCI_SUCCESS;
}

sword ConnectToDb(const char* const uid, const char* const pwd)
{
    sword orc;

    /* allocate Server and Authentication (Session) handles */
    orc = OCIHandleAlloc((dvoid *) envhp, 
                         (dvoid **) &srvhp,
                         (ub4) OCI_HTYPE_SERVER, 
                         (size_t) 0, (dvoid **) 0);

    orc = OCIHandleAlloc((dvoid *) envhp, 
                         (dvoid **) &authp,
                         (ub4) OCI_HTYPE_SESSION, 
                         (size_t) 0, (dvoid **) 0);
    
    /* attach to the server */
    orc = OCIServerAttach(srvhp, errhp, (text *) 0, 0, (ub4) OCI_DEFAULT);
     
    orc = OCIAttrSet((dvoid *) authp, 
                     (ub4) OCI_HTYPE_SESSION,
                     (dvoid *) uid, (ub4) strlen((char *)uid),
                     (ub4) OCI_ATTR_USERNAME, errhp);
    
    orc = OCIAttrSet((dvoid *) authp, 
                     (ub4) OCI_HTYPE_SESSION,
                     (dvoid *) pwd, (ub4) strlen((char *)pwd),
                     (ub4) OCI_ATTR_PASSWORD, errhp);

    /* set the server attribute in the service context */
    orc = OCIAttrSet((dvoid *) svchp, 
                     (ub4) OCI_HTYPE_SVCCTX,
                     (dvoid *) srvhp, 
                     (ub4) 0, (ub4) OCI_ATTR_SERVER, errhp);
     
    /* log on */
    orc = OCISessionBegin(svchp, errhp, authp, 
                          (ub4) OCI_CRED_RDBMS,
                          (ub4) OCI_DEFAULT);
     
    CheckErr(errhp, orc);

    /* set the session attribute in the service context */
    orc = OCIAttrSet((dvoid *) svchp, (ub4) OCI_HTYPE_SVCCTX, 
                     (dvoid *) authp,
                     (ub4) 0, (ub4) OCI_ATTR_SESSION, errhp);

    return (orc);
} /* ConnectToDb */


void CheckErr(OCIError *errhp, sword status)
{
    sb4 errcode = 0;
    text errbuf[512];

    (void) OCIErrorGet((dvoid *)errhp, (ub4) 1, (text *) NULL, &errcode,
                       errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
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
        (void) printf("Make sure you have run the insert statement with the same options as select..\n");
        break;
    case OCI_ERROR:
        (void) OCIErrorGet((dvoid *)errhp, (ub4) 1, (text *) NULL, &errcode,
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
}

void TurnOnSqlTrace()
{
   OCIStmt *stmttracehp;
   static text *stmt_traceon   = (text *)"alter session set events '10046 trace name context forever, level 8'"; 

   CheckErr(errhp, OCIHandleAlloc(envhp, (dvoid **) &stmttracehp,
                                     OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0));

   CheckErr(errhp, OCIStmtPrepare(stmttracehp, errhp, (CONST text *) stmt_traceon,
                                     strlen((char *) stmt_traceon), OCI_NTV_SYNTAX, OCI_DEFAULT));

   CheckErr(errhp, OCIStmtExecute(svchp, stmttracehp, errhp, (ub4) 1, (ub4) 0,
                                     (CONST OCISnapshot *) 0, (OCISnapshot *) 0, OCI_DEFAULT));
}

int CheckLobType()
{
   OCIStmt *stmtlobtypehp;
   OCIDefine *defv1 = 0;
   char LobType[4];

   static text *stmt_lobtype  = (text *)"SELECT securefile from user_lobs where table_name='FOO' and column_name='DOCUMENT' ";

   LobType[3]='\0';

   CheckErr(errhp, OCIHandleAlloc(envhp, (dvoid **) &stmtlobtypehp,
                                     OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0));

   CheckErr(errhp, OCIStmtPrepare(stmtlobtypehp, errhp, (CONST text *) stmt_lobtype,
                                     strlen((char *) stmt_lobtype), OCI_NTV_SYNTAX, OCI_DEFAULT));

   CheckErr(errhp, OCIDefineByPos (stmtlobtypehp, (OCIDefine **) &defv1, errhp,
                         1, &LobType, 4, SQLT_STR,
                         (dvoid *)0, (ub2 *)0, (ub2 *)0, OCI_DEFAULT));

   CheckErr(errhp, OCIStmtExecute(svchp, stmtlobtypehp, errhp, (ub4) 1, (ub4) 0,
                                     (CONST OCISnapshot *) 0, (OCISnapshot *) 0, OCI_DEFAULT));
  if ( (strcmp(LobType, "YES")) == 0 ) 
     return (1) ;
  else
     return (0) ;

}

void PrepareDbTime()
{
   OCIBind *bndv1 = 0;
   OCIBind *bndv2 = 0;

   static text *stmt_cputime = (text *) "begin :cpu_time_value := dbms_utility.get_cpu_time(); end;" ;
   static text *stmt_elptime = (text *) "begin :elp_time_value := dbms_utility.get_time(); end;" ;

   /* Allocate cpu time handle */ 
   CheckErr(errhp, OCIHandleAlloc(envhp, (dvoid **) &stmt_cputimehp,
                                     OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0));

   /* Allocate elapsed time handle */ 
   CheckErr(errhp, OCIHandleAlloc(envhp, (dvoid **) &stmt_elptimehp,
                                     OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0));

   /* Prepare cpu time statement */
   CheckErr(errhp, OCIStmtPrepare(stmt_cputimehp, errhp, (CONST text *) stmt_cputime,
                                     strlen((char *) stmt_cputime), OCI_NTV_SYNTAX, OCI_DEFAULT));

   /* Prepare elapsed time statement */
   CheckErr(errhp, OCIStmtPrepare(stmt_elptimehp, errhp, (CONST text *) stmt_elptime,
                                     strlen((char *) stmt_elptime), OCI_NTV_SYNTAX, OCI_DEFAULT));

   /* Bind cpu_time_value variable */
   CheckErr(errhp, OCIBindByName(stmt_cputimehp, (OCIBind **) &bndv1, errhp,
                         (text *)":cpu_time_value", (sb4) 15, &cpu_time_value, (sb4) sizeof(ub4), SQLT_INT,
                         (dvoid *) 0, (ub2 *) 0, (ub2 *) 0, (ub4) 0, (ub4 *) 0, OCI_DEFAULT));

   /* Bind elp_time_value variable */
   CheckErr(errhp, OCIBindByName(stmt_elptimehp, (OCIBind **) &bndv2, errhp,
                         (text *)":elp_time_value", (sb4) 15, &elp_time_value, (sb4) sizeof(ub4), SQLT_INT,
                         (dvoid *) 0, (ub2 *) 0, (ub2 *) 0, (ub4) 0, (ub4 *) 0, OCI_DEFAULT));
}

ub4 GetDbTime(int ReqTime)
{
   ub4 time_value=0;

   if (ReqTime == 1) {
     CheckErr(errhp, OCIStmtExecute(svchp, stmt_elptimehp, errhp, (ub4) 1, (ub4) 0,
                                     (CONST OCISnapshot *) 0, (OCISnapshot *) 0, OCI_DEFAULT));
     return elp_time_value;
   }
   else if (ReqTime == 0) {
     CheckErr(errhp, OCIStmtExecute(svchp, stmt_cputimehp, errhp, (ub4) 1, (ub4) 0,
                                     (CONST OCISnapshot *) 0, (OCISnapshot *) 0, OCI_DEFAULT));
     return cpu_time_value;
   }
   else {
    printf ("GetDbTime() - ReqTime should be 1 or 0 \n");
    exit(-1);
   }
}

/* end of file LobUtilFunc.c */

