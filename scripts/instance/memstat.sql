select * from v$sga order by value desc;

column name format a50;
column value format 999999999999999999999 
select name,value, unit from v$pgastat order by value desc;

select pool, name, round(bytes/1024/1024) MB from v$sgastat where bytes > 1024*1024 order by bytes desc, name;