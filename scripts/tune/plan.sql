select  child_number,  substr( rpad(' ',2*depth) || operation || ' ' || object_owner || ' ' || object_name || ' ' || options, 1, 100 ) plan,
cost, cpu_cost, io_cost, cardinality
from v$sql_plan where  sql_id = '&sql_id' order by child_number, id;