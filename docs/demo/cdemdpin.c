#ifdef RCSID
static char *RCSid =
   "$Header: cdemdpin.c 15-aug-2006.10:05:43 jkaloger Exp $ ";
#endif /* RCSID */

/*
**      Copyright (c)  2001 Oracle Corporation.  All rights reserved.
*/

/* 
** Directions:
** 1. make -f demo_rdbms.mk build_dp EXE=cdemdpin OBJS=cdemdpin.o
**        makes the cdemdpin executable
** 2. sqlplus OE/OE @cdemdp9i.sql 
**        creates the Oracle 9.0 types tbl
** 3. cdemdpin < cdemdpin.dat
**        runs the executable
** 4. to retrieve data, select from "dp_api_demo1" as "OE/OE"
**
*/

/*
   NAME
     cdemdpin         An example C program that loads a derived object type
                        via Direct Path API.

   DESCRIPTION
      A client module to be used with the cdemodp.c driver.

   NOTES
     This module loads selected types as defined in the Sample Schema.
     Refer to Cdemdp9i.sql for more information on the use of the
     Sample Schema with the DP API demo modules.

   MODIFIED   (MM/DD/YY)
   jkaloger     08/15/06 - Lowercase passwords for secure verifiers project
   cmlim        09/11/01 - fix lint
   eegolf       04/04/01 - Merged eegolf_demo_update
   eegolf       03/29/01 - Creation
 */

#include <sys/types.h>
#include <oci.h>
#include <cdemodp.h>


externdef struct col  objx_01_col [] =
{
  {
    (text *)"customer_id", 0, SQLT_CHR, (text *)0,
    (sword)0, (sword)0, (ub2)0, (ub1)0, (struct obj *) 0
  },
  {
    (text *)"account_mgr_id", 0, SQLT_CHR, (text *)0,
    (sword)0, (sword)0, (ub2)0, (ub1)0, (struct obj *) 0
  }
};

externdef struct fld  objx_01_fld [] =
{
  { 26, 31,  6, FLD_INLINE|FLD_STRIP_TRAIL_BLANK },     /* customer_id */
  { 32, 37,  6, FLD_INLINE|FLD_STRIP_TRAIL_BLANK }      /* account_mgr_id */
};

externdef struct obj corporate_customer_typ =
{
  (text *) "CORPORATE_CUSTOMER_TYP", 2, objx_01_col, objx_01_fld, 0, 0, 
  (OCIDirPathFuncCtx *)0, (OCIDirPathColArray *)0, OBJ_OBJ};


externdef struct col column[] =
{
  {
    (text *)"cust_first_name", 0, SQLT_CHR, (text *)0,
    (sword)0, (sword)0, (ub2)0, (ub1)0
  },
  {
    (text *)"cust_last_name", 0, SQLT_CHR, (text *)0,
    (sword)0, (sword)0, (ub2)0, (ub1)0
  },
  {
    (text *)"cust_more_info", 0, SQLT_NTY, (text *)0,
    (sword)0, (sword)0, (ub2)0, (ub1)0, & corporate_customer_typ 
  }
};

/* Field descriptor which maps one-to-one with the column descriptor.
 * For this simple example, fields are strictly positional within
 * an input record.
 */
externdef struct fld field[] =
{
  { 1, 10, 10, FLD_INLINE|FLD_STRIP_TRAIL_BLANK },       /* cust_first_name */
  { 11,20, 10, FLD_INLINE|FLD_STRIP_TRAIL_BLANK },       /* cust_last_name */
  { 21,25,  5, FLD_INLINE|FLD_STRIP_TRAIL_BLANK }        /* cust_more_info */
};


externdef struct tbl table =
{
  (text *)"OE",                                          /* table owner */
  (text *)"dp_api_demo1",                                 /* table name */
  (text *)""         ,             /* subname (partition, subpartition) */
  (ub2)(sizeof(column) / sizeof(struct col)),      /* number of columns */
  (text *)"DD-MON-YY",                           /* default date format */
  (struct col *)(&column[0]),                     /* column descriptors */
  (struct fld *)(&field[0]),                       /* field descriptors */
  (ub1)0,                                                   /* parallel */
  (ub1)0,                                                      /* nolog */
  (ub4)(64 * 1024)                              /* transfer buffer size */
};

externdef struct sess session =
{
  (text *)"oe",                                              /* user */
  (text *)"oe",                                            /* passwd */
  (text *)"",                                          /* instance name */
  (text *)0,                   /* output file name; NULL implies stderr */
  (ub4)130                                   /* max input record length */
};


/* end of file cdemdpin .c */

