grant create any context, create trigger, ADMINISTER DATABASE TRIGGER to hr;
GRANT EXECUTE ON DBMS_SESSION TO hr;

create context mid_ctx using set_mgr_id_ctx_pkg;

create or replace package set_mgr_id_ctx_pkg is
 procedure set_mgr_id;
end;
/

create or replace package body set_mgr_id_ctx_pkg is
  procedure set_mgr_id is
mgr_id hr.employees.manager_id%type;
begin
  select manager_id into mgr_id from hr.employees where email= sys_context('userenv','session_user');
  dbms_session.set_context('mid_ctx', 'mgr_id', mgr_id);
exception
  when no_data_found then null;
end;
end;
/

create or replace trigger set_mgr_id_ctx_trig after logon on database
begin
	 set_mgr_id_ctx_pkg.set_mgr_id;
end ;
/

  