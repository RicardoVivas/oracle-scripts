-- Run as non-SYS user
create table uow_flashback_table (id number) ;
select current_scn, systimestamp from v$database;
insert into uow_flashback_table values (1); 
commit;
select count(*) from uow_flashback_table;
alter table uow_flashback_table enable row movement;
flashback table uow_flashback_table to timestamp <>;

-- ORA-08185: Flashback not supported for user SYS
select count(*) from uow_flashback_table;