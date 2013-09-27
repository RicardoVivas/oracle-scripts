rem
rem  Summary of every metric in past one-hour period. Not suitable for detailed drill  
rem  dba_hist_sysmetirc_summary will contains a sna of of this table. 
rem
select  metric_name, round(maxval,2), minval, round(average,2), metric_unit , begin_time, round(intsize_csec/100/60) interval_min
from v$sysmetric_summary 
order by begin_time desc, metric_name;