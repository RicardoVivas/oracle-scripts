-- Copied from oracle docs "security guide"

-- run as sysdba

grant create session, create any context, create procedure, create trigger, administer database trigger to sysadmin_vpd identified by password;
grant execute on dbms_session to sysadmin_vpd;
grant execute on dbms_rls to sysadmin_vpd;

GRANT CREATE SESSION TO tbrooke IDENTIFIED BY password;
GRANT CREATE SESSION TO owoods IDENTIFIED BY password;


-- login as scott:

CREATE TABLE customers (
 cust_no    NUMBER(4), 
 cust_email VARCHAR2(20),
 cust_name  VARCHAR2(20)
 );

INSERT INTO customers VALUES (1234, 'TBROOKE', 'Thadeus Brooke');
INSERT INTO customers VALUES (5678, 'OWOODS', 'Oberon Woods');


CREATE TABLE orders_tab (
  cust_no  NUMBER(4),
  order_no NUMBER(4)
);

INSERT INTO orders_tab VALUES (1234, 9876);
INSERT INTO orders_tab VALUES (5678, 5432);
INSERT INTO orders_tab VALUES (5678, 4592);

GRANT SELECT ON orders_tab TO tbrooke;
GRANT SELECT ON orders_tab TO owoods;
GRANT SELECT ON customers TO sysadmin_vpd;

-- login as sysadmin_vpd
create or replace context orders_ctx using orders_ctx_pkg;

create or replace package orders_ctx_pkg is
 procedure set_custnum;  
end;

create or replace package body orders_ctx_pkg is
 procedure set_custnum
 as
  custnum number;
 begin
  select cust_no into custnum from scott.customers where cust_email = sys_context('userenv','session_user');
  dbms_session.set_context('orders_ctx', 'cust_no', custnum);
 exception 
  when no_data_found then null;
 end set_custnum;
end;
/

create trigger set_custno_ctx_trig after logon on database
 begin
	sysadmin_vpd.orders_ctx_pkg.set_custnum;
 end;
/

create or replace function get_user_orders(schema_p in varchar2, table_p varchar2)
return varchar2
as
orders_pred varchar2 (400);
begin
	 orders_pred := 'cust_no = sys_context (''orders_ctx'',''cust_no'')';
	 return orders_pred;
end;
/

begin
	dbms_rls.add_policy (
	 object_schema => 'scott',
	 object_name => 'orders_tab',
	 policy_name => 'orders_policy',
	 function_schema => 'sysadmin_vpd',
	 policy_function => 'get_user_orders',
	 statement_types => 'select');
end;
/



--



























