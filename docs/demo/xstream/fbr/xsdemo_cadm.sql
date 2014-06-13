Rem
Rem $Header: rdbms/demo/xstream/fbr/xsdemo_cadm.sql /main/1 2009/02/27 15:57:39 tianli Exp $
Rem
Rem xsdemo_cadm.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates.All rights reserved. 
Rem
Rem    NAME
Rem      xsdemo_cadm.sql - create stradm user and grant privilege
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tianli      02/20/09 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

drop user stradm cascade;
grant resource, connect to stradm identified by stradm;
grant dba to stradm;
exec dbms_streams_auth.grant_admin_privilege(grantee =>'stradm');
