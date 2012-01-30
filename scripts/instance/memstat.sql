select * from v$sga;

column name format a50;
select name,value, unit from v$pgastat;

select * from v$sgastat order by name;



