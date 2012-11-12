select sql_id, child_number,  substr( rpad(' ',2*depth) || operation || ' ' || object_owner || ' ' || object_name || ' ' || options, 1, 100 ) plan,cost, 
cpu_cost, io_cost, cardinality
from v$sql_plan where  PLAN_HASH_VALUE = '&PLAN_HASH_VALUE' order by sql_id, child_number, id;