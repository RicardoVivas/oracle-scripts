/
/ $Header: rdbms/demo/xstream/scalewp/README.txt /st_rdbms_11.2.0/1 2010/08/13 18:32:29 vchandar Exp $
/
/ README.txt
/
/ Copyright (c) 2010, Oracle. All Rights Reserved.
/
/   NAME
/     README.txt - Readme file for running the demo implementation of
/                  "Building Highly Scalable Web Application with XStream"
/
/   DESCRIPTION
/     
/
/   NOTES
/     <other useful comments, qualifications, etc.>
/
/   MODIFIED   (MM/DD/YY)
/   vchandar    08/12/10 - Creation
/
****************************************************************************
** This README describes how to run the demo implementation of the 
** Oracle Whitepaper "Building Highly Scalable Web Application with XStream"
****************************************************************************

System Setup :

To be able to run this demo program. 
1) You need to have three physical instances of Oracle 11g database (11.2.0.2 
   or later). For simplicity of illustration, we have colocated the customer
   and item tables (and hence the respective xins) on the same physical 
   database
2) You can create db links inst1,inst2,inst3 at each of the databases, for the 
   sql setup script to connect to the databases. inst1 will be used as 
   the web front end DB (xout). inst2, inst3 will be used for sharded customer 
   and item databases (XIN s).
3) Enable ARCHIVELOG mode for inst1, which will be used for XStream Out
4) Set up TCP listeners on all three databases.

Files :
1. wpsetup.sql
   This sql script sets up the XStream admin user needed on
   all three databases, creates the tables and the statement handlers, 
   runs a small workload.
2. wp.properties
   Sample configuration file for the XStream Client program 
   (WPClient). Modify the sid, listener port, host, sid of the three databases 
   according to your environment. The descriptions in the properties file
   should be straightforward.
3. WPClient.java
   Java client program to attach to the xout at inst1, construct the xin 
   transactions to the customer/item xins at inst2, inst3.

To run the demo :

1. Run wpsetup.sql from the web front end database (inst1).
     @wpsetup.sql <inst1_sys_passwd> <inst2_sys_passwd> <inst3_sys_passwd>
2) Compile and run the client

   a) source <rdbms/demo/xstream/java/xsdemo_env.sh>
   b) javac WPClient.java
   c) java WPClient <properties-file> <xstream_admin_passwd>

Notes :
1. You could kill the java client using 
    kill -9 `ps -aef | grep "java WPClient" | grep -v grep | awk '{print $2}'`
   to test recovery

2. If you want to turn DEBUG messages off, change "debug" key in the 
   properties files

