column component format a40;
select component, current_size/1024/1024, max_size/1024/1024, last_oper_mode, last_oper_type, last_oper_time  from v$memory_dynamic_components order by current_size desc;
select component, sum(current_size)/1024/1024, sum(max_size)/1024/1024 from v$memory_dynamic_components  group by cube(component)  order by 2;