rem
rem $Header: rdbms/demo/oci12.sql /main/6 2010/02/26 13:15:31 azhao Exp $
rem
rem Copyright (c) 1995, 2010, Oracle and/or its affiliates. 
rem All rights reserved. 
rem
rem    NAME
rem      oci12.sql
rem    DESCRIPTION
rem      Script for A22400 OCI Techniques White Paper
rem      Demo script for oci12.c
rem    RETURNS
rem
rem    NOTES
rem      <other useful comments, qualifications, etc.>
rem    MODIFIED   (MM/DD/YY)
rem     azhao      02/25/10  - remove hard-coded password, bug 9364818
rem     azhao      10/11/06  - case-senstive password change
rem     mjaeger    07/14/99 -  bug 808870: OCCS: convert tabs, no long lines
rem     cchau      08/18/97 -  enable dictionary protection
rem     echen      01/10/97 -  change internal to sys/change_on_install
rem     vraghuna   03/01/95 -  Creation

set echo on;
define PASSWORD=&1
connect sys/&PASSWORD as sysdba;
drop user ocitest cascade;
create user ocitest identified by OCITEST;
grant connect,resource to ocitest;
connect ocitest/OCITEST;

create table oci12tab (col1 number, col2 long);

insert into oci12tab values(1,  'A');
insert into oci12tab values(2,  'AB');
insert into oci12tab values(3,  'ABC');
insert into oci12tab values(4,  'ABCDEFGHIJKLM');
insert into oci12tab values(5,  'ABCD');
insert into oci12tab values(6,  'ABCDE');
insert into oci12tab values(7,  'ABCDEFGHIJ');
insert into oci12tab values(8,  '1');
insert into oci12tab values(9,  '12');
insert into oci12tab values(10, '123');
insert into oci12tab values(11, '123456789');
insert into oci12tab values(12, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
commit;
