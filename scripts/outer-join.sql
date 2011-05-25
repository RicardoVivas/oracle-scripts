## test outer join
drop table product;
create table product (id number, prod_name varchar2(20));
insert into product values (2, 'desk');
insert into product values (3, 'computer');
insert into product values (1, 'chair');

drop table myorder;
create table myorder (id number, prod_id number);
insert into myorder values (101, 1);
insert into myorder values (102, 2);
insert into myorder values (103, 2);
insert into myorder values (104, 4);

drop table orderline;
create table orderline (id number, order_id number, prod_id number);
insert into  orderline values (10001, 101, 1);
insert into  orderline values (10002, 102, 2);

commit;

select a.*, b.*, c.* from 
product a 
left join myorder b on a.id = b.prod_id
left join orderline c on a.id = c.prod_id;


select a.*, b.*, c.* from 
product a 
left join myorder b on a.id = b.prod_id
left join orderline c on b.id = c.order_id;