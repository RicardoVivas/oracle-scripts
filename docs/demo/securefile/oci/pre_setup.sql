Rem
Rem $Header: pre_setup.sql 22-mar-2007.13:39:54 vdjegara Exp $
Rem
Rem pre_setup.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      pre_setup.sql - <one-line expansion of the name>
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

spool pre_setup.log

connect / as sysdba

create tablespace lob_demo_ts datafile '<your datafile path>' size 2000M reuse
extent management local uniform size 64M segment space management auto;

CREATE USER lob_demo
    IDENTIFIED BY lob_demo
    DEFAULT TABLESPACE lob_demo_ts
    QUOTA unlimited ON lob_demo_ts;

grant dba, connect, resource to lob_demo;
grant ALL PRIVILEGES to lob_demo;

spool off
