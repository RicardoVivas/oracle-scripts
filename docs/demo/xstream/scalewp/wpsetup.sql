Rem
Rem $Header: rdbms/demo/xstream/scalewp/wpsetup.sql /st_rdbms_11.2.0/1 2010/08/13 18:32:29 vchandar Exp $
Rem
Rem wpsetup.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      wpsetup.sql - setup script for the demo implemetation of Oracle
Rem      whitepaper "Building Highly Scalable Web Application with XStream"
Rem
Rem    DESCRIPTION
Rem      Sets up users and creates schema on all three instances
Rem      The three databases have the following roles 
Rem      inst1 - web store front end db
Rem      inst2,inst3 - customer databases
Rem      inst2,inst3 - item databases
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vchandar    08/12/10 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- <CHANGE> this setup works with a single web front end db and two sharded
-- databases each for customer and item tables. 
-- this can be modified suitably for how many ever sharded instances you want

define inst1_sys_passwd=&1
define inst2_sys_passwd=&2
define inst3_sys_passwd=&3

-- Store the DB links
DEFINE webdb='inst1'
DEFINE cust1db='inst2'
DEFINE cust2db='inst3'
DEFINE item1db='inst2'
DEFINE item2db='inst3'

-------------------------------------------------------------------------------=
-- Create admin user with XStream/Streams admin priviledges
-- at all databases
-------------------------------------------------------------------------------=
CONNECT sys/&inst1_sys_passwd@&webdb AS SYSDBA
create tablespace xstream_tbs datafile '?/xstream_tbs1.dbf' 
  size 50M reuse autoextend on maxsize unlimited;

create user wpadmin identified by wpadmin 
  default tablespace xstream_tbs
  quota unlimited on xstream_tbs;

-- grant permissions
grant resource, connect to wpadmin identified by wpadmin;
grant dba to wpadmin;
exec dbms_streams_auth.grant_admin_privilege(grantee => 'wpadmin');
exec dbms_xstream_auth.grant_admin_privilege(grantee => 'wpadmin');

CONNECT sys/&inst2_sys_passwd@&cust1db AS SYSDBA
create tablespace xstream_tbs datafile '?/xstream_tbs2.dbf' 
  size 50M reuse autoextend on maxsize unlimited;

create user wpadmin identified by wpadmin 
  default tablespace xstream_tbs
  quota unlimited on xstream_tbs;

-- grant permissions
grant resource, connect to wpadmin identified by wpadmin;
grant dba to wpadmin;
exec dbms_streams_auth.grant_admin_privilege(grantee => 'wpadmin');
exec dbms_xstream_auth.grant_admin_privilege(grantee => 'wpadmin');

CONNECT sys/&inst3_sys_passwd@&cust2db AS SYSDBA

create tablespace xstream_tbs datafile '?/xstream_tbs3.dbf' 
  size 50M reuse autoextend on maxsize unlimited;

create user wpadmin identified by wpadmin 
  default tablespace xstream_tbs
  quota unlimited on xstream_tbs;

-- grant permissions
grant resource, connect to wpadmin identified by wpadmin;
grant dba to wpadmin;
exec dbms_streams_auth.grant_admin_privilege(grantee => 'wpadmin');
exec dbms_xstream_auth.grant_admin_privilege(grantee => 'wpadmin');

-------------------------------------------------------------------------------=
-- CREATE THE TABLES AT THE DIFFERENT DATABASES
-------------------------------------------------------------------------------=

-------------------------------------------------------------------------------=
-- WEBFRONTEND contains orders & order_line tables.
-- actual user transactions hit these tables and are then
-- migrated over to the appropriate customer database through XOUT
-------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&webdb
create table orders (order_id number primary key,
              cust_id number);
create table order_line(order_id number,
                        line_num number,
                        item_id number,
                        quantity  number,
                        cost number,
                        PRIMARY KEY(order_id, line_num));
grant all on orders to system;
grant all on order_line to system;

-------------------------------------------------------------------------------=
-- CUSTOMER databases contain customer, orders, order_line
-- All the data from the webfrontend gets eventually consolidated here
-------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&cust1db
create table orders (order_id number primary key,
              cust_id number);
create table order_line(order_id number,
                        line_num number,
                        item_id number,
                        quantity  number,
                        cost number,
                        PRIMARY KEY(order_id, line_num));
create table customer (cust_id number primary key,
                       balance number);

grant all on orders to system;
grant all on order_line to system;
grant all on customer to system;

conn wpadmin/wpadmin@&cust2db
create table orders (order_id number primary key,
              cust_id number);
create table order_line(order_id number,
                        line_num number,
                        item_id number,
                        quantity  number,
                        cost number,
                        PRIMARY KEY(order_id, line_num));

create table customer (cust_id number primary key,
                       balance number);
grant all on orders to system;
grant all on order_line to system;
grant all on customer to system;

-------------------------------------------------------------------------------=
-- ITEM databases store the item table alone. 
-- the inventories are eventually consolidated from the webfrontend
-------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&item1db
create table item (item_id number primary key,
                   quantity number,
                   price number,
                   description varchar2(100));
grant all on item to system;


conn wpadmin/wpadmin@&item2db
create table item (item_id number primary key,
                   quantity number,
                   price number,
                   description varchar2(100));
grant all on item to system;


------------------------------------------------------------------------------=
-- DO SOME INITAL DATA LOAD INTO THE DBS
-- system starts with 0 orders. customer and item information are 
-- statically partitioned across (cust1db,cust2db) and 
-- (item1db, item2db) respectively
------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&cust1db
begin 
  for i in 1 .. 200 loop 
    if mod(i, 2) = 0 then
      insert into customer values (i, trunc(dbms_random.value(1,10000), 0));
    end if; 
  end loop;
  commit;
end;
/

conn wpadmin/wpadmin@&cust2db
begin 
  for i in 1 .. 200 loop 
    if mod(i, 2) = 1 then
      insert into customer values (i, trunc(dbms_random.value(1,10000), 0));
    end if;
  end loop;
  commit;
end;
/

conn wpadmin/wpadmin@&item1db
begin 
  for i in 1 .. 1000 loop
    if mod(i, 2) = 0 then
      insert into item values (i, trunc(dbms_random.value(10,100), 0),
                              trunc(dbms_random.value(100,500), 0),
                              'description' || i);
     end if;
  end loop;
  commit;
end;
/

conn wpadmin/wpadmin@&item2db
begin 
  for i in 1 .. 1000 loop
    if mod(i, 2) = 1 then
      insert into item values (i, trunc(dbms_random.value(10,100), 0),
                               trunc(dbms_random.value(100,500), 0),
                              'description' || i);
    end if;
  end loop;
  commit;
end;
/

------------------------------------------------------------------------------=
--                 SETUP XSTREAM
--
------------------------------------------------------------------------------=

------------------------------------------------------------------------------=
--  Create an XOUT at the webfront db
------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&webdb
begin
  dbms_xstream_adm.create_outbound('WEB_OUT');
end;
/

------------------------------------------------------------------------------=
-- Create XINs at customer databases to update the customer balance
-- and also to migrate the order information from the webfront
------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&cust1db

begin
  dbms_xstream_adm.create_inbound(
          server_name => 'cust1_in',
          queue_name  => 'cust1_queue',
          comment     => 'CUST DB 1 XStreams In');
end;
/
exec dbms_apply_adm.start_apply('cust1_in');

conn wpadmin/wpadmin@&cust2db
begin
  dbms_xstream_adm.create_inbound(
          server_name => 'cust2_in',
          queue_name  => 'cust2_queue',
          comment     => 'CUST DB 2 XStreams In');
end;
/
exec dbms_apply_adm.start_apply('cust2_in');

------------------------------------------------------------------------------=
-- Create XINs at the item databases to update the product inventory.
------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&item1db
begin
  dbms_xstream_adm.create_inbound(
            server_name => 'item1_in',
            queue_name  => 'item1_queue',
            comment     => 'ITEM1 XStreams In');
end;
/
exec dbms_apply_adm.start_apply('item1_in');

conn wpadmin/wpadmin@&item2db
begin
  dbms_xstream_adm.create_inbound(
            server_name => 'item2_in',
            queue_name  => 'item2_queue',
            comment     => 'ITEM2 XStreams In');
end;
/
exec dbms_apply_adm.start_apply('item2_in');

-------------------------------------------------------------------------------=
-- ADD STATEMENT HANDLERS
-- Note: since the updates to item and customer tables happen asynchronously,
-- they cannot be updated using the (old,new) column value pair, as when 
-- it was read. Hence, we use a statement handler to make these updates
-- based on the current value in the destination.
-------------------------------------------------------------------------------=

-------------------------------------------------------------------------------=
-- Add statement handler to intercept updates to customer table.
-------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&cust1db
begin
  dbms_apply_adm.add_stmt_handler(
    object_name => 'WPADMIN.CUSTOMER',
    operation_name => 'UPDATE',
    handler_name => 'CUST_HDLR1',
    statement => 'update wpadmin.customer set balance = balance - :new.balance where cust_id = :new.cust_id',
    apply_name => 'CUST1_in');    
end;
/

conn wpadmin/wpadmin@&cust2db
begin
  dbms_apply_adm.add_stmt_handler(
    object_name => 'WPADMIN.CUSTOMER',
    operation_name => 'UPDATE',
    handler_name => 'CUST_HDLR2',
    statement => 'update wpadmin.customer set balance = balance - :new.balance where cust_id = :new.cust_id',
    apply_name => 'CUST2_in');
end;
/

-------------------------------------------------------------------------------=
-- Add statement handler to intercept updates to the item table
-------------------------------------------------------------------------------=
conn wpadmin/wpadmin@&item1db
begin
  dbms_apply_adm.add_stmt_handler(
    object_name => 'WPADMIN.ITEM',
    operation_name => 'UPDATE',
    handler_name => 'ITEM_HDLR1',
    statement => 'update wpadmin.item set quantity = quantity - :new.quantity where item_id = :new.item_id',
    apply_name => 'ITEM1_IN');
end;
/

conn wpadmin/wpadmin@&item2db
begin
  dbms_apply_adm.add_stmt_handler(
    object_name => 'WPADMIN.ITEM',
    operation_name => 'UPDATE',
    handler_name => 'ITEM_HDLR2',
    statement => 'update wpadmin.item set quantity = quantity - :new.quantity where item_id = :new.item_id',
    apply_name => 'ITEM2_IN');
end;
/

------------------------------------------------------------------------------=
-- run some traffic
------------------------------------------------------------------------------=
-- Synthetic traffic to cross validate correctness
conn wpadmin/wpadmin@&cust1db
select * from customer where (cust_id >= 1 and cust_id <= 5) or (cust_id >= 101 and cust_id <= 105);

conn wpadmin/wpadmin@&cust2db
select * from customer where (cust_id >= 1 and cust_id <= 5) or (cust_id >= 101 and cust_id <= 105);

conn wpadmin/wpadmin@&item1db
select * from item where item_id = 12;

conn wpadmin/wpadmin@&item2db
select * from item where item_id = 511;

conn wpadmin/wpadmin@&webdb
insert into orders values(1, 1);
insert into order_line values(1, 1, 12, 10, 20);
insert into order_line values(1, 2, 511, 10, 20);
commit;

insert into orders values(2, 2);
insert into order_line values(2, 1, 12, 10, 20);
insert into order_line values(2, 2, 511, 10, 20);
commit;

insert into orders values(3, 3);
insert into order_line values(3, 1, 12, 10, 20);
insert into order_line values(3, 2, 511, 10, 20);
commit;

insert into orders values(4, 4);
insert into order_line values(4, 1, 12, 10, 20);
insert into order_line values(4, 2, 511, 10, 20);
commit;

insert into orders values(5, 5);
insert into order_line values(5, 1, 12, 10, 20);
insert into order_line values(5, 2, 511, 10, 20);
commit;

insert into orders values(6, 101);
insert into order_line values(6, 1, 12, 10, 20);
insert into order_line values(6, 2, 511, 10, 20);
commit;

insert into orders values(7, 102);
insert into order_line values(7, 1, 12, 10, 20);
insert into order_line values(7, 2, 511, 10, 20);
commit;

insert into orders values(8, 103);
insert into order_line values(8, 1, 12, 10, 20);
insert into order_line values(8, 2, 511, 10, 20);
commit;

insert into orders values(9, 104);
insert into order_line values(9, 1, 12, 10, 20);
insert into order_line values(9, 2, 511, 10, 20);
commit;

insert into orders values(10, 105);
insert into order_line values(10, 1, 12, 10, 20);
insert into order_line values(10, 2, 511, 10, 20);
commit;

exit;

-- random traffic
declare
  o number;
  i number;
begin
  for o in 11 .. 100 loop
    insert into orders values(o, trunc(dbms_random.value(1,200), 0));
    for i in 1 ..  trunc(dbms_random.value(1,4),0) loop
      insert into order_line values(o, i, trunc(dbms_random.value(1, 1000),0), 
                  trunc(dbms_random.value(1,50), 0), 
                  trunc(dbms_random.value(10,200), 0));
    end loop;
    commit;
  end loop;
end;
/

