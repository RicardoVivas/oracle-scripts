-- Only current minute
select  substr(metric_name,1,30), round(value, 1), metric_unit, begin_time, round(intsize_csec/100) interval_sec from v$sysmetric order by begin_time desc, metric_name;