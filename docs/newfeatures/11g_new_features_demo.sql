
alter session set nls_date_format='dd/mm/yy';
alter session set nls_timestamp_format = 'dd/mm/yy';
col OBJECT_NAME format a10
col SUBOBJECT_NAME format a10
col  owner format a10
set autotrace on;
set line 300
set echo on

-- 1. invisible index
pause 
drop table TEST_INDEX;
create table TEST_INDEX as select * from all_objects where rownum < 10000;

create index idx_test_oid on TEST_INDEX ( object_id ) ;
pause
  
select * from TEST_INDEX where object_id = 20;

pause  
-- now make index invisible
alter index idx_test_oid invisible;
pause

select * from TEST_INDEX where object_id = 30;
pause 

-- now make index visible
alter index idx_test_oid visible;
pause

select * from TEST_INDEX where object_id = 30;
pause 

-- 2. demo read-only table 
pause

set autotrace off;
insert into  TEST_INDEX (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID, OBJECT_TYPE, CREATED, LAST_DDL_TIME, NAMESPACE)  
values('HSUN', 'JAVA', NULL, -1, -2, 'TABLE', SYSDATE, SYSDATE, 4);
COMMIT;

pause 
-- now make table read only 
ALTER TABLE TEST_INDEX READ ONLY;
pause

insert into  TEST_INDEX (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID, OBJECT_TYPE, CREATED, LAST_DDL_TIME, NAMESPACE)  
values('HSUN', 'JAVA7', NULL, -2, -3, 'TABLE', SYSDATE, SYSDATE, 4);

pause

ALTER TABLE TEST_INDEX READ WRITE;
pause

insert into  TEST_INDEX (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID, OBJECT_TYPE, CREATED, LAST_DDL_TIME, NAMESPACE)  
values('HSUN', 'JAVA7', NULL, -2, -3, 'TABLE', SYSDATE, SYSDATE, 4);


pause 
-- 3. Demo interval partition 

drop table test_partition purge;
Create table test_partition (object_name varchar2(50), object_id number, created date) 
partition by range(created) interval (numtoyminterval(1, 'MONTH'))
(
   partition partition_1 values less than ( to_date( '01-jan-2010', 'dd-mon-yyyy') )
);
pause 


INSERT INTO test_partition  SELECT OBJECT_NAME, object_id, created from all_objects where rownum < 10000;
pause 

-- Now check the automatically created partition. Partitions without data are not created
select table_name, PARTITION_NAME, HIGH_VALUE, PARTITION_POSITION from user_tab_partitions where table_name ='TEST_PARTITION' order by PARTITION_POSITION ; 
pause


-- 4. Demo virtual column
pause 

drop table TEST_VCOLUMN purge;

create table TEST_VCOLUMN (object_id  , object_name, owner) as select object_id, object_name, owner from all_objects where rownum < 500;
pause

ALTER TABLE TEST_VCOLUMN ADD (NAME_LOWCASE GENERATED ALWAYS AS (LOWER(OBJECT_NAME)));
pause

create index idx_test3_namelow on TEST_VCOLUMN (name_lowcase);
pause

select * from TEST_VCOLUMN where  name_lowcase = 'i_user1';
pause

insert into test_vcolumn (object_id  , object_name, owner, name_lowcase)  values (-1, 'HELPTEXT', 'SB2TEST', 'test');
pause

insert into test_vcolumn (object_id  , object_name, owneR) values (-1, 'HELPTEXT', 'SB2TEST');
pause;


ALTER TABLE TEST_VCOLUMN ADD (NAME_UPCASE GENERATED ALWAYS AS (upper(OBJECT_NAME)));
pause

create index idx_TEST_VCOLUMN_nameupper on TEST_VCOLUMN (name_upcase);
pause 

--it is actually a function-based index
select INDEX_NAME, INDEX_TYPE from user_indexes where table_name ='TEST_VCOLUMN';
pause 


-- 5. LISTAGG is a built-in function that enables us to perform string aggregation natively

col tables format a100
drop table test4 purge;

create table test4 as select owner, table_name from dba_tables where owner not in ('SYSTEM', 'SYS', 'SYSMAN', 'WMSYS', 'OUTLN');
pause;

SELECT OWNER, LISTAGG(TABLE_NAME, ',') WITHIN GROUP (ORDER BY TABLE_NAME) AS TABLES FROM TEST4 GROUP BY OWNER;
pause

 
-- 6. DML ERROR logging since 10g R2:
pause

drop table test5 purge;
drop table TEST5_ERRORS purge;
create table test5 as select owner, table_name from dba_tables where 1 = 0;
pause

CREATE UNIQUE INDEX IDX_TEST5_TNAME ON TEST5 (TABLE_NAME);
pause;

insert into test5 values ('SB2TEST', 'SITE');
COMMIT;
pause


EXEC DBMS_ERRLOG.CREATE_ERROR_LOG(DML_TABLE_NAME => 'TEST5', ERR_LOG_TABLE_NAME => 'TEST5_ERRORS');
pause

set lin 100

desc test5
pause

DESC TEST5_ERRORS;
pause

set lin 200
col ORA_ERR_MESG$ format a80
col owner format a15
col table_name format a15


SELECT ORA_ERR_MESG$, owner, table_name FROM TEST5_ERRORS;
pause

-- REJECT LIMIT UNLIMITED DEFAULT IS 0
INSERT INTO TEST5   select owner, table_name from dba_tables where owner not in ('SYSTEM', 'SYS', 'SYSMAN') LOG ERRORS INTO TEST5_ERRORS ('FIRST_TEST') REJECT LIMIT UNLIMITED;
pause

SELECT ORA_ERR_MESG$, owner, table_name FROM TEST5_ERRORS;
pause
 
--   7 Demo  add not null default value
alter table TEST_INDEX add elab varchar2(50) default  'webteam' not null;
pause

 -- 8 Segment creation on demand

