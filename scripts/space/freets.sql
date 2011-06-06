CLEAR
SET VERIFY OFF
BREAK on report
COMPUTE sum of free_ts_size on report
COMPUTE sum of tot_ts_size on report
SELECT                                                            /* + RULE */
         df.tablespace_name tspace, 
         df.BYTES / (1024 * 1024) tot_size_mb,
         round(SUM (fs.BYTES) / (1024 * 1024),1) free_size_mb,
         NVL (ROUND (SUM (fs.BYTES) * 100 / df.BYTES), 1) free
         --ROUND ((df.BYTES - SUM (fs.BYTES)) * 100 / df.BYTES) ts_pct1
  FROM dba_free_space fs,
       (SELECT   tablespace_name, SUM (BYTES) BYTES  FROM dba_data_files   GROUP BY tablespace_name) df
   WHERE fs.tablespace_name(+) = df.tablespace_name
GROUP BY df.tablespace_name, df.BYTES
UNION ALL
select tf.tablespace_name tspace, 
tf.total_bytes/1024/1024 tot_size_mb,
th.total_free_bytes/1024/1024 free_size_mb,
round(100 * th.total_free_bytes/tf.total_bytes) ts_pct1
from
(select  tablespace_name, sum(bytes) total_bytes from  dba_temp_files  group by tablespace_name) tf,
(select  tablespace_name, sum(bytes_free) total_free_bytes from v$temp_space_header group by tablespace_name ) th
where tf.tablespace_name = th.tablespace_name
group by tf.tablespace_name,tf.total_bytes, th.total_free_bytes
ORDER BY 4 