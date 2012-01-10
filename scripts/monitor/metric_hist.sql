-- Within one hour
select  metric_name, to_char(value,'9,999,999') val, metric_unit, begin_time, round(intsize_csec/100) interval_sec 
from v$sysmetric_history where intsize_csec > 5000 and value > 10 and metric_name in 
('Consistent Read Gets Per Sec', 'DB Block Changes Per Sec', 'Database CPU Time Ratio',
'Executions Per Sec', 'Logical Reads Per Sec', 
'Network Traffic Volume Per Sec', 'Physical Read Bytes Per Sec',
'Physical Write Bytes Per Sec','Redo Generated Per Sec',
'User Commits Per Sec')
 order by  metric_name, begin_time desc;