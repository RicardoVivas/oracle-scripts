Rem
Rem $Header: rdbms/demo/aqdemo08.sql /st_rdbms_11.2.0/1 2011/01/21 10:54:40 rbhyrava Exp $
Rem
Rem aqdemo08.sql
Rem
Rem Copyright (c) 2001, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      aqdemo08.sql - AQ Notifications Demo 
Rem
Rem    DESCRIPTION
Rem       Make sure the database is started with following parameters
Rem        aq_tm_processes =2 
Rem        job_queue_processes=2
Rem        compatible=8.1.0 # or above 
Rem       Modify the email host , port and sendfrom .
Rem       Modify the email you@company.com to valid email address
Rem    NOTES
Rem      This demo does the following 
Rem       - setup mail server - change mailhost and sender email address
Rem       - setup users/queues/queue tables 
Rem       - Create callback functions used in registration 
Rem       - Register for event notification for the subscriber ADMIN 
Rem       - Registrations are added using default presentation  
Rem            and xml presentation 
Rem       - Register for grouping notifications 
Rem       - Do enqueues 
Rem       - Verify notifications 
Rem       - Cleanup
Rem 
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem    rbhyrava    01/12/11 - XbranchMerge rbhyrava_notifdemo from main
Rem    rbhyrava    12/16/10 - grouping registrations
Rem    rbhyrava    11/16/04 - user
Rem    ksurlake    06/10/04 - 3229354: Wait before unregistering
Rem    rbhyrava    05/16/01 - fix typo /
Rem    rbhyrava    04/29/01 - Merged rbhyrava_aqxmltype_demos
Rem    rbhyrava    04/27/01 - Created
Rem

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO ON
spool aqdemo08.log
CONNECT sys/change_on_install as sysdba;
SET SERVEROUTPUT ON
SET ECHO ON

Rem set the mailserver etc.
call dbms_aqelm.set_mailhost('youmailhost.company.com');
call dbms_aqelm.set_mailport(25);
call dbms_aqelm.set_sendfrom('you@company.com');

Rem user pubsub1 is used for registering on a queue
DROP USER pubsub1 CASCADE;
CREATE USER pubsub1 IDENTIFIED BY pubsub1;

Rem grant all the roles to pubsub1
GRANT connect, resource, dba TO pubsub1;
GRANT aq_administrator_role, aq_user_role TO pubsub1;
GRANT EXECUTE ON dbms_aq TO pubsub1;
GRANT EXECUTE ON dbms_aqadm TO pubsub1;
EXECUTE dbms_aqadm.grant_type_access('pubsub1');
EXECUTE dbms_aqadm.grant_system_privilege('ENQUEUE_ANY','pubsub1',FALSE);
EXECUTE dbms_aqadm.grant_system_privilege('DEQUEUE_ANY','pubsub1',FALSE);

CONNECT pubsub1/pubsub1;

rem stop the adt queue
BEGIN
DBMS_AQADM.STOP_QUEUE('pubsub1.adtevents');
END;
/

rem drop the adt queue
BEGIN
DBMS_AQADM.DROP_QUEUE(QUEUE_NAME=>'pubsub1.adtevents');
END;
/

rem drop the adt queue table
BEGIN
DBMS_AQADM.DROP_QUEUE_TABLE(QUEUE_TABLE => 'pubsub1.adt_msg_table', force => TRUE);
END;
/

rem create the adt
CREATE OR REPLACE TYPE adtmsg AS OBJECT (id NUMBER, data VARCHAR2(4000)) ;
/

rem create the raw queue table
BEGIN
DBMS_AQADM.CREATE_QUEUE_TABLE(
    QUEUE_TABLE=>'pubsub1.raw_msg_table',
    MULTIPLE_CONSUMERS => TRUE,
    QUEUE_PAYLOAD_TYPE =>'RAW',
    COMPATIBLE => '8.1.3');
END;
/

rem creat the adt queue table
BEGIN
DBMS_AQADM.CREATE_QUEUE_TABLE(
    QUEUE_TABLE=>'pubsub1.adt_msg_table',
    MULTIPLE_CONSUMERS => TRUE,
    QUEUE_PAYLOAD_TYPE =>'ADTMSG',
    COMPATIBLE => '8.1.3');
END;
/
rem  Create a queue for raw events
BEGIN
DBMS_AQADM.CREATE_QUEUE(QUEUE_NAME=>'pubsub1.events',
            QUEUE_TABLE=>'pubsub1.raw_msg_table',
            COMMENT=>'Q for events triggers');
END;
/

rem  Create a queue for adt events
BEGIN
DBMS_AQADM.CREATE_QUEUE(QUEUE_NAME=>'pubsub1.adtevents',
            QUEUE_TABLE=>'pubsub1.adt_msg_table',
            COMMENT=>'Q for adt events triggers');
END;
/

rem start the queues
BEGIN
DBMS_AQADM.START_QUEUE('pubsub1.events');
END; 
/

BEGIN
DBMS_AQADM.START_QUEUE('pubsub1.adtevents');
END;
/
rem Create a non-persistent queue for events
BEGIN
 DBMS_AQADM.CREATE_NP_QUEUE(QUEUE_NAME=>'pubsub1.nonperevents',
            MULTIPLE_CONSUMERS => TRUE);
END;
/

rem start the np queue
BEGIN
DBMS_AQADM.START_QUEUE('pubsub1.nonperevents');
END;
/

rem procedure to enqueue raw into persistent queue
CREATE OR REPLACE PROCEDURE new_rawenqueue(queue_name  IN VARCHAR2,
                                     correlation  IN VARCHAR2 := NULL,
                                     exception_queue  IN VARCHAR2 := NULL)
AS

enq_ct     dbms_aq.enqueue_options_t;
msg_prop   dbms_aq.message_properties_t;
enq_msgid  RAW(16);
userdata   RAW(1000);

BEGIN
    msg_prop.exception_queue := exception_queue;
    msg_prop.correlation := correlation;
    userdata := hextoraw('666');

    DBMS_AQ.ENQUEUE(queue_name, enq_ct, msg_prop, userdata, enq_msgid);
END;
/
GRANT EXECUTE ON new_rawenqueue TO PUBLIC;

rem procedure to enqueue adt into persistent queue
CREATE OR REPLACE PROCEDURE new_adtenqueue(queue_name  IN VARCHAR2,
                                     correlation  IN VARCHAR2 := NULL,
                                     exception_queue  IN VARCHAR2 := NULL)
AS

enq_ct     dbms_aq.enqueue_options_t;
msg_prop   dbms_aq.message_properties_t;
enq_msgid  raw(16);
payload    adtmsg;

BEGIN
    msg_prop.exception_queue := exception_queue;
    msg_prop.correlation := correlation;
    payload := adtmsg(1, 'p queue Hello World!');

    DBMS_AQ.ENQUEUE(queue_name, enq_ct, msg_prop, payload, enq_msgid);
END;
/
GRANT EXECUTE ON new_adtenqueue TO PUBLIC;

rem create procedure to enqueue raw into np queue
CREATE OR REPLACE PROCEDURE new_np_rawenqueue(queue  VARCHAR2,
                                           id  INTEGER,
                                           correlation  VARCHAR2)
AS

msgprop        dbms_aq.message_properties_t;
enqopt         dbms_aq.enqueue_options_t;
enq_msgid      RAW(16);
payload        RAW(10);

BEGIN
    payload := hextoraw('999');
    enqopt.visibility:=dbms_aq.IMMEDIATE;
    msgprop.correlation:=correlation;
    FOR i IN 1..10 LOOP
       DBMS_AQ.ENQUEUE( queue, enqopt, msgprop, payload, enq_msgid);
    END LOOP;
END;
/
GRANT EXECUTE ON new_np_rawenqueue TO PUBLIC;

rem create procedure to enqueue adt into np queue
CREATE OR REPLACE PROCEDURE new_np_adtenqueue(queue  VARCHAR2,
                                           id  INTEGER,
                                           correlation  VARCHAR2)
AS

msgprop        dbms_aq.message_properties_t;
enqopt         dbms_aq.enqueue_options_t;
enq_msgid      raw(16);
payload        adtmsg;

BEGIN
    payload := adtmsg(1, 'np queue Hello World!');
    enqopt.visibility:=dbms_aq.IMMEDIATE;
    msgprop.correlation:=correlation;
    FOR i IN 1..5 LOOP
    DBMS_AQ.ENQUEUE( queue, enqopt, msgprop, payload, enq_msgid);
    END LOOP;
END;
/
GRANT EXECUTE ON new_np_adtenqueue TO PUBLIC;

DECLARE
   subscriber sys.aq$_agent;

BEGIN

   subscriber := sys.aq$_agent('admin', null, null);

   dbms_aqadm.add_subscriber(queue_name => 'pubsub1.events',
                          subscriber => subscriber);

   dbms_aqadm.add_subscriber(queue_name => 'pubsub1.adtevents',
                          subscriber => subscriber);

   dbms_aqadm.add_subscriber(queue_name => 'pubsub1.nonperevents',
                          subscriber => subscriber);

   subscriber := sys.aq$_agent('admin_new', null, null);

   dbms_aqadm.add_subscriber(queue_name => 'pubsub1.events',
                          subscriber => subscriber);

   dbms_aqadm.add_subscriber(queue_name => 'pubsub1.adtevents',
                          subscriber => subscriber);

   dbms_aqadm.add_subscriber(queue_name => 'pubsub1.nonperevents',
                          subscriber => subscriber);

END;
/

SET ECHO ON;
CONNECT sys/change_on_install  as sysdba;
set serveroutput on;

DROP TABLE plsqlregtr;
CREATE TABLE plsqlregtr
(
  descr    sys.aq$_descriptor,
  reginfo  sys.aq$_reg_info,
  payload  RAW(2000),
  payloadl NUMBER
);

GRANT ALL ON plsqlregtr TO PUBLIC;

DROP TABLE plsqlregtn;
CREATE TABLE plsqlregtn
(
  descr    sys.aq$_descriptor,
  reginfo  sys.aq$_reg_info,
  payload  RAW(2000),
  payloadl NUMBER
);

GRANT ALL ON plsqlregtn TO PUBLIC;

DROP TABLE plsqlregta;
CREATE TABLE plsqlregta
(
  descr    sys.aq$_descriptor,
  reginfo  sys.aq$_reg_info,
  payload  VARCHAR2(4000),
  payloadl NUMBER
);

GRANT ALL ON plsqlregta TO PUBLIC;

DROP TABLE plsqlregtp;
CREATE TABLE plsqlregtp
(
  descr    sys.aq$_descriptor,
  reginfo  sys.aq$_reg_info,
  payload  VARCHAR2(4000),
  payloadl NUMBER
);

GRANT ALL ON plsqlregtp TO PUBLIC;

CONNECT pubsub1/pubsub1

CREATE OR REPLACE PROCEDURE plsqlregproc1(
   context RAW , reginfo sys.aq$_reg_info, descr sys.aq$_descriptor, 
   payload RAW,  payloadl NUMBER)
AS
BEGIN
  INSERT INTO sys.plsqlregtr (descr, reginfo, payload, payloadl) 
         VALUES (descr, reginfo, payload, payloadl);
END;
/
CREATE OR REPLACE PROCEDURE plsqlregproc2(
   context RAW , reginfo sys.aq$_reg_info, descr sys.aq$_descriptor, 
   payload VARCHAR2,  payloadl NUMBER)
AS
BEGIN
  INSERT INTO sys.plsqlregta (descr, reginfo, payload, payloadl) 
         VALUES (descr, reginfo, payload, payloadl);
END;
/
CREATE OR REPLACE PROCEDURE plsqlregproc3(
   context RAW , reginfo sys.aq$_reg_info, descr sys.aq$_descriptor, 
   payload RAW,  payloadl NUMBER)
AS
BEGIN
  INSERT INTO sys.plsqlregtn (descr, reginfo, payload, payloadl) 
         VALUES (descr, reginfo, payload, payloadl);
END;
/
CREATE OR REPLACE PROCEDURE plsqlregproc4(
   context RAW , reginfo sys.aq$_reg_info, descr sys.aq$_descriptor, 
   payload VARCHAR2,  payloadl NUMBER)
AS
BEGIN
  INSERT INTO sys.plsqlregtp (descr, reginfo, payload, payloadl) 
         VALUES (descr, reginfo, payload, payloadl);
END;
/
rem  Do all the registerations
SET ECHO ON;
CONNECT pubsub1/pubsub1;
SET SERVEROUTPUT ON;

DECLARE

  reginfo1            sys.aq$_reg_info;
  reginfo2            sys.aq$_reg_info;
  reginfo3            sys.aq$_reg_info;
  reginfo4            sys.aq$_reg_info;
  reginfo5            sys.aq$_reg_info;
  reginfo6            sys.aq$_reg_info;
  reginfo7            sys.aq$_reg_info;
  reginfo8            sys.aq$_reg_info;
  reginfo9            sys.aq$_reg_info;
  reginfolist         sys.aq$_reg_info_list;

BEGIN
-- register for p raw q default pres
  reginfo1 := sys.aq$_reg_info('PUBSUB1.EVENTS:ADMIN',1,'plsql://plsqlregproc1',HEXTORAW('FF'));

-- register for p raw q xml pres
  reginfo2 := sys.aq$_reg_info('PUBSUB1.EVENTS:ADMIN',1,'plsql://plsqlregproc1?PR=1',HEXTORAW('FF'));

-- register for p adt q default pres
  reginfo3 := sys.aq$_reg_info('PUBSUB1.ADTEVENTS:ADMIN',1,'plsql://plsqlregproc2',HEXTORAW('FF'));

-- register for p adt q xml pres
  reginfo4 := sys.aq$_reg_info('PUBSUB1.ADTEVENTS:ADMIN',1,'plsql://plsqlregproc2?PR=1',HEXTORAW('FF'));

-- for np q raw and adt can be enqueued into the same queue
-- register for np raw and adt q default pres
  reginfo5 := sys.aq$_reg_info('PUBSUB1.NONPEREVENTS:ADMIN',1,'plsql://plsqlregproc1',HEXTORAW('FF'));

-- register for np raw and adt q xml pres
  reginfo6 := sys.aq$_reg_info('PUBSUB1.NONPEREVENTS:ADMIN',1,'plsql://plsqlregproc2?PR=1',HEXTORAW('FF'));

-- grouping registration 

-- qosflags 
-- NTFN_QOS_RELIABLE- 
--     specifies reliable notification,
--     persist across instance and database restarts.
-- NTFN_QOS_PAYLOAD - 
--     payload delivery is required. 
--     It is supported only for client notification for only RAW queues.
-- NTFN_QOS_PURGE_ON_NTFN - 
--     registration is purged automatically when the first notification is delivered to this registration location

-- NTFN_GROUPING_CLASS_TIME:
--     Notifications grouped by time, that is, the user specifies a time value 
--     and a single notification gets published at the end of that time.

-- ntfn_grouping_type
--  NTFN_GROUPING_TYPE_SUMMARY - Summary of all notifications that occurred in the time interval. (Default)
--  NTFN_GROUPING_TYPE_LAST - Last notification that occurred in the interval.
 
-- ntfn_grouping_start_time 
-- Notification grouping start time. 
-- Notification grouping can start from a user-specified time 
--    that should a valid timestamp with time zone. 
-- If ntfn_grouping_start_time is not specified when using grouping, 
--     the default is to current timestamp with time zone

--ntfn_grouping_value 
-- Time-period of grouping notifications specified in seconds, 
-- meaning the time after which grouping notification would be sent periodically until ntfn_grouping_repeat_count is exhausted.
 
-- ntfn_grouping_repeat_count
--  Grouping notifications will be sent as many times as specified by the notification grouping repeat count and after that 
--       revert to regular notifications. The ntfn_grouping_repeat_count, 
--  if not specified, will default to Keep sending grouping notifications forever
-- NTFN_GROUPING_FOREVER  valid values ( 0, -1 , numeric)

 reginfo7 := sys.aq$_reg_info(
                       name => 'PUBSUB1.EVENTS:ADMIN_NEW',
                       namespace => 1,
                       callback => 'plsql://plsqlregproc3',
                       context => HEXTORAW('FF'),
                       anyctx => null,
                       ctxtype => 0,
                       qosflags => dbms_aq.NTFN_QOS_PURGE_ON_NTFN,
                       payloadcbk => null,
                       timeout => 120,
                       ntfn_grouping_class=> dbms_aq.NTFN_GROUPING_CLASS_TIME,
                       ntfn_grouping_value => 1,
                       ntfn_grouping_type =>dbms_aq.NTFN_GROUPING_TYPE_LAST,
                       ntfn_grouping_start_time=> systimestamp,
                       ntfn_grouping_repeat_count =>10) ;

 reginfo8 := sys.aq$_reg_info(
                       name => 'PUBSUB1.ADTEVENTS:ADMIN_NEW',
                       namespace => 1,
                       callback => 'plsql://plsqlregproc4',
                       context => HEXTORAW('FF'),
                       anyctx => null,
                       ctxtype => 0,
                       qosflags => dbms_aq.NTFN_QOS_PURGE_ON_NTFN,
                       payloadcbk => null,
                       timeout => 120,
                       ntfn_grouping_class=> dbms_aq.NTFN_GROUPING_CLASS_TIME,
                       ntfn_grouping_value => 2,
                       ntfn_grouping_type =>dbms_aq.NTFN_GROUPING_TYPE_SUMMARY,
                       ntfn_grouping_start_time=> systimestamp,
                       ntfn_grouping_repeat_count =>dbms_aq.NTFN_GROUPING_FOREVER) ;

  reginfolist := sys.aq$_reg_info_list(reginfo1);
  reginfolist.EXTEND;
  reginfolist(2) := reginfo2;
  reginfolist.EXTEND;
  reginfolist(3) := reginfo3;
  reginfolist.EXTEND;
  reginfolist(4) := reginfo4;
  reginfolist.EXTEND;
  reginfolist(5) := reginfo5;
  reginfolist.EXTEND;
  reginfolist(6) := reginfo6;
  reginfolist.EXTEND;
  reginfolist(7) := reginfo7;
  reginfolist.EXTEND;
  reginfolist(8) := reginfo8;
  sys.dbms_aq.register(reginfolist, 8);
  commit;

-- registerations are done

END;
/

Rem Do all the registerations
CONNECT pubsub1/pubsub1;
SET ECHO ON;
SET SERVEROUTPUT ON;

DECLARE

  reginfo1            sys.aq$_reg_info;
  reginfo2            sys.aq$_reg_info;
  reginfo3            sys.aq$_reg_info;
  reginfo4            sys.aq$_reg_info;
  reginfo5            sys.aq$_reg_info;
  reginfo6            sys.aq$_reg_info;
  reginfo7            sys.aq$_reg_info;
  reginfolist         sys.aq$_reg_info_list;

BEGIN
-- register for p raw q default pres
  reginfo1 := sys.aq$_reg_info('PUBSUB1.EVENTS:ADMIN',1,'mailto://you@company.com',HEXTORAW('FF'));

-- register for p raw q xml pres
  reginfo2 := sys.aq$_reg_info('PUBSUB1.EVENTS:ADMIN',1,'mailto://you@company.com?PR=1',HEXTORAW('FF'));

-- register for p adt q default pres
  reginfo3 := sys.aq$_reg_info('PUBSUB1.ADTEVENTS:ADMIN',1,'mailto://you@company.com',HEXTORAW('FF'));

-- register for p adt q xml pres
  reginfo4 := sys.aq$_reg_info('PUBSUB1.ADTEVENTS:ADMIN',1,'mailto://you@company.com?PR=1',HEXTORAW('FF'));

-- for np q raw and adt can be enqueued into the same queue
-- register for np raw and adt q default pres
  reginfo5 := sys.aq$_reg_info('PUBSUB1.NONPEREVENTS:ADMIN',1,'mailto://you@company.com',HEXTORAW('FF'));

-- register for np raw and adt q xml pres
  reginfo6 := sys.aq$_reg_info('PUBSUB1.NONPEREVENTS:ADMIN',1,'mailto://you@company.com?PR=1',HEXTORAW('FF'));

  reginfolist := sys.aq$_reg_info_list(reginfo1);
  reginfolist.EXTEND;
  reginfolist(2) := reginfo2;
  reginfolist.EXTEND;
  reginfolist(3) := reginfo3;
  reginfolist.EXTEND;
  reginfolist(4) := reginfo4;
  reginfolist.EXTEND;
  reginfolist(5) := reginfo5;
  reginfolist.EXTEND;
  reginfolist(6) := reginfo6;

  sys.dbms_aq.register(reginfolist, 6);

  COMMIT;

-- registrations are done

END;
/
CONNECT pubsub1/pubsub1;
SET ECHO ON;
SET SERVEROUTPUT ON;

DECLARE
BEGIN
-- wait for registerations to happen
--  dbms_lock.sleep(90);

-- now start enqueing

-- raw into p queue
  new_rawenqueue('PUBSUB1.EVENTS', 'PR CORRELATION STRING', 'PREQ');
  commit;

-- adt into p queue
  new_adtenqueue('PUBSUB1.ADTEVENTS', 'PA CORRELATION STRING', 'PAEQ');
  commit;

-- raw into np queue
  new_np_rawenqueue('PUBSUB1.NONPEREVENTS', 1, 'NPR CORRELATION STRING'); 
  commit;

-- adt into np queue
  new_np_adtenqueue('PUBSUB1.NONPEREVENTS', 1, 'NPA CORRELATION STRING');
  commit;

END;
/
exec dbms_lock.sleep(2);
REM should see 2 registrations for new admin user 
CONNECT sys/change_on_install as sysdba 
SELECT b.SUBSCRIPTION_NAME, num_ntfns, num_grouping_ntfns,
           last_ntfn_sent_time, total_emon_latency, 
           total_plsql_exec_time, last_err, last_err_time
   from v$subscr_registration_stats a, reg$ b where a.reg_id = b.reg_id 
   and subscription_name like '%ADMIN_NEW%' order by 1;


DECLARE
BEGIN
-- wait for PL/SQL callbacks to be invoked
  dbms_lock.sleep(120);
END;
/

set echo on;
CONNECT pubsub1/pubsub1;
SET SERVEROUTPUT ON;

SELECT count(*) FROM sys.plsqlregtr t;
SELECT count(*) FROM sys.plsqlregta t;

REM since there are from grouping notifications should see 1 row each 
SELECT count(*) FROM sys.plsqlregtn t;
SELECT count(*) FROM sys.plsqlregtp t;

CONNECT sys/change_on_install as sysdba 

REM the subscriptions are auto purged 
SELECT SUBSTR(b.SUBSCRIPTION_NAME,1,20) subscriber_name,
       num_ntfns, 
       num_grouping_ntfns,
       last_ntfn_sent_time, 
       total_emon_latency
   FROM v$subscr_registration_stats a, reg$ b 
  WHERE a.reg_id = b.reg_id 
   AND  subscription_name LIKE '%ADMIN_NEW%' ORDER BY 1;

REM select registrations. the registrations with ADMIN_NEW subscriber are purged automatically as they are purge on notification
SELECT SUBSTR(Subscription_name,1,20) subscription_name ,  
       status, 
       qosflags, 
       ntfn_grouping_class,
       ntfn_grouping_value,
       ntfn_grouping_type,
       ntfn_grouping_start_time,
       ntfn_grouping_repeat_count,state 
 FROM reg$ order by 1,2,3,4,5,6; 

REM Do all the unregisterations
CONNECT pubsub1/pubsub1;
SET ECHO ON;
SET SERVEROUTPUT ON;

DECLARE
  reginfo1            sys.aq$_reg_info;
  reginfo2            sys.aq$_reg_info;
  reginfo3            sys.aq$_reg_info;
  reginfo4            sys.aq$_reg_info;
  reginfo5            sys.aq$_reg_info;
  reginfo6            sys.aq$_reg_info;
  reginfolist         sys.aq$_reg_info_list;

BEGIN
-- register for p raw q default pres
  reginfo1 := sys.aq$_reg_info('PUBSUB1.EVENTS:ADMIN',1,'plsql://plsqlregproc1',HEXTORAW('FF'));

-- register for p raw q xml pres
  reginfo2 := sys.aq$_reg_info('PUBSUB1.EVENTS:ADMIN',1,'plsql://plsqlregproc1?PR=1',HEXTORAW('FF'));

-- register for p adt q default pres
  reginfo3 := sys.aq$_reg_info('PUBSUB1.ADTEVENTS:ADMIN',1,'plsql://plsqlregproc2',HEXTORAW('FF'));

-- register for p adt q xml pres
  reginfo4 := sys.aq$_reg_info('PUBSUB1.ADTEVENTS:ADMIN',1,'plsql://plsqlregproc2?PR=1',HEXTORAW('FF'));

-- for np q raw and adt can be enqueued into the same queue
-- register for np raw and adt q default pres
  reginfo5 := sys.aq$_reg_info('PUBSUB1.NONPEREVENTS:ADMIN',1,'plsql://plsqlregproc1',HEXTORAW('FF'));

-- register for np raw and adt q xml pres
  reginfo6 := sys.aq$_reg_info('PUBSUB1.NONPEREVENTS:ADMIN',1,'plsql://plsqlregproc2?PR=1',HEXTORAW('FF'));

  reginfolist := sys.aq$_reg_info_list(reginfo1);
  reginfolist.EXTEND;
  reginfolist(2) := reginfo2;
  reginfolist.EXTEND;
  reginfolist(3) := reginfo3;
  reginfolist.EXTEND;
  reginfolist(4) := reginfo4;
  reginfolist.EXTEND;
  reginfolist(5) := reginfo5;
  reginfolist.EXTEND;
  reginfolist(6) := reginfo6;
  sys.dbms_aq.unregister(reginfolist, 6);

  COMMIT;

-- unregisterations are done

END;
/
REM Do all the unregisterations
CONNECT pubsub1/pubsub1;
SET ECHO ON;
SET SERVEROUTPUT ON;

DECLARE

  reginfo1            sys.aq$_reg_info;
  reginfo2            sys.aq$_reg_info;
  reginfo3            sys.aq$_reg_info;
  reginfo4            sys.aq$_reg_info;
  reginfo5            sys.aq$_reg_info;
  reginfo6            sys.aq$_reg_info;
  reginfolist         sys.aq$_reg_info_list;

BEGIN
-- register for p raw q default pres
  reginfo1 := sys.aq$_reg_info('PUBSUB1.EVENTS:ADMIN',1,'mailto://you@company.com',HEXTORAW('FF'));

-- register for p raw q xml pres
  reginfo2 := sys.aq$_reg_info('PUBSUB1.EVENTS:ADMIN',1,'mailto://you@company.com?PR=1',HEXTORAW('FF'));

-- register for p adt q default pres
  reginfo3 := sys.aq$_reg_info('PUBSUB1.ADTEVENTS:ADMIN',1,'mailto://you@company.com',HEXTORAW('FF'));

-- register for p adt q xml pres
  reginfo4 := sys.aq$_reg_info('PUBSUB1.ADTEVENTS:ADMIN',1,'mailto://you@company.com?PR=1',HEXTORAW('FF'));

-- for np q raw and adt can be enqueued into the same queue
-- register for np raw and adt q default pres
  reginfo5 := sys.aq$_reg_info('PUBSUB1.NONPEREVENTS:ADMIN',1,'mailto://you@company.com',HEXTORAW('FF'));

-- register for np raw and adt q xml pres
  reginfo6 := sys.aq$_reg_info('PUBSUB1.NONPEREVENTS:ADMIN',1,'mailto://you@company.com?PR=1',HEXTORAW('FF'));

  reginfolist := sys.aq$_reg_info_list(reginfo1);
  reginfolist.EXTEND;
  reginfolist(2) := reginfo2;
  reginfolist.EXTEND;
  reginfolist(3) := reginfo3;
  reginfolist.EXTEND;
  reginfolist(4) := reginfo4;
  reginfolist.EXTEND;
  reginfolist(5) := reginfo5;
  reginfolist.EXTEND;
  reginfolist(6) := reginfo6;
  sys.dbms_aq.unregister(reginfolist, 6);
  COMMIT;
-- unregisterations are done

END;
/
CONNECT sys/change_on_install as  sysdba;

drop user pubsub1 cascade ;
drop table plsqlregtr ;
drop table plsqlregta ;
drop table plsqlregtn ;
drop table plsqlregtp ;

spool off
exit ;
