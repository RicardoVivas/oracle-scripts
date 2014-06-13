#!/bin/sh
#
# $Header: setup.sh 22-mar-2007.13:39:58 vdjegara Exp $
#
# setup.sh
#
# Copyright (c) 2007, Oracle. All rights reserved.  
#
#    NAME
#      setup.sh - <one-line expansion of the name>
#
#    DESCRIPTION
#      <short description of component this file declares/defines>
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    vdjegara    01/29/07 - 
#    vdjegara    01/29/07 - Creation
#

echo "Creating table foo, because pkgs depend on it.."
echo " "
sqlplus -s lob_demo/lob_demo @cr_tab.sql securefile AUTO >setup.log

echo "Loading all procedures for plsql demo.."
echo " "
sqlplus lob_demo/lob_demo <<! >>setup.log
set echo on

create or replace directory FILEDIR as '/tmp';

@LocatorAPI_Insert.sql
show error
@LocatorAPI_Select.sql
show error

@DataAPI_Insert.sql
show error
@DataAPI_Select.sql
show error
!

echo "Compiling Test Data generator program .."
echo " "
rm -f GenDemoDataFile GenDemoDataFile.o
make GenDemoDataFile >>setup.log
echo "Making a test file (DocumentFile.dat) in /tmp directory.."
echo " "
GenDemoDataFile /tmp/DocumentFile.dat 102400000 >>setup.log

echo "Check setup.log for any error.."
echo " "

