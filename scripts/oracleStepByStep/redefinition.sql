
----------As root---------------------------
create user hsuntest identified by hsuntest748348u0 default tablespace users quota unlimited on users;
grant create session, create table, create view, create trigger to hsuntest;

create table hsuntest.parent (id number);
alter table hsuntest.parent add constraint pk_parent_id primary key (id);

create table hsuntest.log (msg varchar2(50));

create table hsuntest.children (id number,pid number,  constraint  pk_id  primary key  (id));
alter table hsuntest.children add constraint fk_pid foreign key (pid) references hsuntest.parent (id);
create view hsuntest.children_less_10_v as select * from children where id < 10;

create or replace trigger hsuntest.children_tri 
before insert or update on hsuntest.children 
for each row 
begin
  insert into log values('new' || :new.id);
end;
/   

insert into hsuntest.parent    select rownum from dual connect by level < 15;
insert into hsuntest.children  select rownum, rownum from dual connect by level < 15;
COMMIT;


set lin 200;
col object_name format a20

select object_name, object_type, status from dba_objects  where owner='HSUNTEST' order by 2, 1 ;
select trigger_name , table_name from dba_triggers where owner='HSUNTEST' order by 2;
select view_name, text from dba_views where owner='HSUNTEST';
select CONSTRAINT_NAME, table_name, status from dba_constraints where owner='HSUNTEST' order by 2;
select table_name, PARTITION_NAME from dba_tab_partitions where  table_owner='HSUNTEST' order by 1;
 
-- -- Check table can be redefined
set feedback on;
EXEC DBMS_REDEFINITION.can_redef_table('HSUNTEST', 'CHILDREN');

create table hsuntest.children_p (id number,pid number) 
 partition by range (id)
 ( partition p1 values less than (5),  
   partition p2 values less than (10),   
   partition p3 values less than (maxvalue)
 );


-- Start Redefinition
EXEC DBMS_REDEFINITION.start_redef_table('HSUNTEST', 'CHILDREN', 'CHILDREN_P');

SET SERVEROUTPUT ON
DECLARE
  l_num_errors PLS_INTEGER;
BEGIN
 DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(uname => 'HSUNTEST',
       orig_table => 'CHILDREN',
       int_table => 'CHILDREN_P', 
       copy_indexes  => DBMS_REDEFINITION.cons_orig_params,
       num_errors => l_num_errors);
 DBMS_OUTPUT.put_line('l_num_errors=' || l_num_errors);
END;
/

-- Optionally synchronize new table with interim data before index creation
EXEC DBMS_REDEFINITION.sync_interim_table('HSUNTEST', 'CHILDREN', 'CHILDREN_P'); 

-- Complete redefinition
EXEC DBMS_REDEFINITION.finish_redef_table( 'HSUNTEST',  'CHILDREN', 'CHILDREN_P');

drop table hsuntest.children_p purge;

select object_name, object_type, status from dba_objects  where owner='HSUNTEST' order by 2, 1 ;
select trigger_name , table_name from dba_triggers where owner='HSUNTEST' order by 2;
select view_name, text from dba_views where owner='HSUNTEST';
select CONSTRAINT_NAME, table_name, status from dba_constraints where owner='HSUNTEST' order by 2;
select table_name, PARTITION_NAME from dba_tab_partitions where  table_owner='HSUNTEST' order by 1;


drop user hsuntest cascade;
exit;
