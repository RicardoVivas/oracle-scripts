rem
rem $Header: rdbms/demo/oci18.sql /main/6 2010/02/26 13:15:31 azhao Exp $
rem
rem Copyright (c) 1995, 2010, Oracle and/or its affiliates. 
rem All rights reserved. 
rem
rem    NAME
rem      oci18.sql
rem    DESCRIPTION
rem      Script for A22400 OCI Techniques White Paper
rem      Demo script for oci18.c
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

create table oci18tab (col1 varchar2(30));

create or replace package oci18pkg as

        type char_array is table of varchar2(30) index by binary_integer;

        function oci18func(
                col1      in char_array,   -- array to put cname in
                numins    in integer)
        return integer;

end;
/

create or replace package body oci18pkg as


        function oci18func(
                col1      in char_array,
                numins    in integer
        ) return integer is retval integer;

        begin

                for i in 1..numins loop
                        insert into oci18tab values (col1(i));
                end loop;
                commit;

                retval := numins;
                return(retval);

        end;

end;
/

commit;

