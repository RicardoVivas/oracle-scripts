Rem
Rem $Header: cr_tab.sql 22-mar-2007.13:39:48 vdjegara Exp $
Rem
Rem cr_tab.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cr_tab.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vdjegara    01/29/07 - 
Rem    vdjegara    01/29/07 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

drop table foo purge;

create table foo (pkey number(10) not null, 
	          DOCUMENT blob) 
	lob(DOCUMENT) store as &1 FOO_DOCUMENT_LOBSEG (NOCACHE LOGGING RETENTION &2);

create unique index pkey_idx on foo (pkey) ;
exit;
