drop table cartesian1 purge;
create table cartesian1 (id number , name varchar2(10));

drop table cartesian2 purge;
create table cartesian2 (id number , name varchar2(10));

-- test
insert into cartesian1 values (1, 'c1_1');
insert into cartesian1 values (2, 'c1_2');

insert into cartesian2 values (1, 'c2_1');
insert into cartesian2 values(2, 'c2_2');
insert into cartesian2 values (3, 'c2_3');
commit;

select a.id as id1, a.name as name1, b.id as id2, b.name as name2 from cartesian1 a, cartesian2 b;