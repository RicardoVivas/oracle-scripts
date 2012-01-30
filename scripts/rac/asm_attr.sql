set pagesize 10
col name format a40
col value format a40
col compatibility format a30
col database_compatibility format a30

select * from v$asm_diskgroup;

select * from v$asm_attribute;
