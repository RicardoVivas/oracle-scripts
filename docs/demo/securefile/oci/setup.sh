#!/bin/ksh
#
# $Header: setup.sh 22-mar-2007.13:39:35 vdjegara Exp $
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

echo "Cleaning up all compiled objects and binaries.."
rm -f *.o LocatorAPI_Insert LocatorAPI_Select DataAPI_Insert DataAPI_Select >setup.log
echo "Compiling objects and binaries.."

make -f $ORACLE_HOME/demo/demo_rdbms.mk build EXE="LocatorAPI_Insert" OBJS="LocatorAPI_Insert.o LobUtilFunc.o" >>setup.log
make -f $ORACLE_HOME/demo/demo_rdbms.mk build EXE="LocatorAPI_Select" OBJS="LocatorAPI_Select.o LobUtilFunc.o" >>setup.log
make -f $ORACLE_HOME/demo/demo_rdbms.mk build EXE="DataAPI_Insert" OBJS="DataAPI_Insert.o LobUtilFunc.o" >>setup.log
make -f $ORACLE_HOME/demo/demo_rdbms.mk build EXE="DataAPI_Select" OBJS="DataAPI_Select.o LobUtilFunc.o" >>setup.log

echo "Check setup.log for any errors.."


