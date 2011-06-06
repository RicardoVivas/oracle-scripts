ALTER TABLE <table_name>
EXCHANGE PARTITION <partition_name>
WITH TABLE <new_table_name>
<including | excluding> INDEXES
<with | without> VALIDATION
EXCEPTIONS INTO <schema.table_name>;


HSUN@perseus SQL>create table objs partition by range (created) interval (numtoyminterval(1, 'MONTH')) (partition partition_1  values less than ( to_date( '01-dec-2005', 'dd-mon-yyyy') ))  as select owner, object_name, object_id, created from dba_objects;

HSUN@perseus SQL>create table objs_tmp (owner VARCHAR2(30), OBJECT_NAME VARCHAR2(128), OBJECT_ID number, CREATED date);

HSUN@perseus SQL>alter table objs exchange partition sys_p3422 with table objs_tmp;

Table altered.

HSUN@perseus SQL>alter table objs exchange partition sys_p3422 with table objs_tmp;

Table altered.

HSUN@perseus SQL>alter table objs exchange partition sys_p3422 with table objs_tmp including indexes;
alter table objs exchange partition sys_p3422 with table objs_tmp including indexes
                                                         *
ERROR at line 1:
ORA-14098: index mismatch for tables in ALTER TABLE EXCHANGE PARTITION

HSUN@perseus SQL>create index idx_objstmp_created on objs_tmp (created);

Index created.

HSUN@perseus SQL>alter table objs exchange partition sys_p3422 with table objs_tmp;

Table altered.
