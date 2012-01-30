rem 
rem Test the 11g reference partition
rem 
drop table child purge;
drop table parent purge;

create table parent (id number,
  constraint pk_parent_id primary key (id)) 
 partition by range (id)
 ( partition p1 values less than (5),  
   partition p2 values less than (10),   
   partition p3 values less than (maxvalue)
 );
 
rem
rem  The column pid must be not NULL
rem  Otherwise get error "ORA-14652: reference partitioning foreign key is not supported"
rem

create table child (
  id number,
  pid number not null, 
  constraint pk_child_id primary key (id),
  constraint fk_child_pid foreign key (pid) references parent(id))  
 partition by reference(fk_child_pid);
 
insert into parent    select rownum from dual connect by level < 15;
insert into child  select rownum, rownum from dual connect by level < 15;
commit;


rem
rem  In 11g, the reference partition is not supported by logical standby. The script will return  
rem
rem 

SELECT DISTINCT OWNER, TABLE_NAME FROM DBA_LOGSTDBY_UNSUPPORTED ORDER BY OWNER;