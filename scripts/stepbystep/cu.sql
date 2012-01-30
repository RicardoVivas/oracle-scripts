create user ops$hsuntest identified by external default tablespace users quota unlimited on users;
grant create session, create table, create view, create trigger to ops$hsuntest;
