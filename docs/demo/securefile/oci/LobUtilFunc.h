/* Copyright (c) 2007, Oracle. All rights reserved.  */
 
/* 
   NAME 
     LobUtilFunc.h -  Lob demo header file

   DESCRIPTION 

   RELATED DOCUMENTS 
 
   EXPORT FUNCTION(S) 

   INTERNAL FUNCTION(S)

   EXAMPLES

   NOTES

   MODIFIED   (MM/DD/YY)
   vdjegara    04/05/07 - Add PrepareDbTime prototype
   vdjegara    01/29/07 - Creation

*/

#include <oci.h>

# ifndef externdef
#  define externdef
# endif

#define USERKEYRANGE       100000

/* Main OCI handle pointers  */
externdef OCIEnv     *envhp;
externdef OCIError   *errhp;
externdef OCISvcCtx  *svchp;
externdef OCIServer  *srvhp;
externdef OCISession *authp;

/* Statement handle to get cpu and elapsed time */
externdef OCIStmt *stmt_cputimehp;
externdef OCIStmt *stmt_elptimehp;
externdef ub4 cpu_time_value;
externdef ub4 elp_time_value;


int main(int argc, char *argv[]);

sword AllocateHandles(ub1);

sword ConnectToDb(const char* const uid, const char* const pwd );

void  CheckErr(OCIError *errhp, sword status);

void  TurnOnSqlTrace();

void  PrepareDbTime();

ub4   GetDbTime(int ReqTime);

int   CheckLobType();


