CLEAR
SET VERIFY OFF
BREAK on report
COMPUTE sum of free_ts_size on report
COMPUTE sum of tot_ts_size on report
SELECT                                                            /* + RULE */
         df.tablespace_name tspace, df.BYTES / (1024 * 1024) tot_size_mb,
         round(SUM (fs.BYTES) / (1024 * 1024),1) free_size_mb,
         NVL (ROUND (SUM (fs.BYTES) * 100 / df.BYTES), 1) free
         --ROUND ((df.BYTES - SUM (fs.BYTES)) * 100 / df.BYTES) ts_pct1
    FROM dba_free_space fs,
         (SELECT   tablespace_name, SUM (BYTES) BYTES
              FROM dba_data_files
          GROUP BY tablespace_name) df
   WHERE fs.tablespace_name(+) = df.tablespace_name
GROUP BY df.tablespace_name, df.BYTES
UNION ALL
SELECT                                                            /* + RULE */
         df.tablespace_name tspace, 
         fs.BYTES / (1024 * 1024) tot_size_mb,
         round(SUM (df.bytes_free) / (1024 * 1024),1) free_size_mb,
         NVL (ROUND ((SUM (fs.BYTES) - df.bytes_used) * 100 / fs.BYTES), 1 ) free
         --ROUND ((SUM (fs.BYTES) - df.bytes_free) * 100 / fs.BYTES) ts_pct1
    FROM dba_temp_files fs,
         (SELECT   tablespace_name, bytes_free, bytes_used
              FROM v$temp_space_header
          GROUP BY tablespace_name, bytes_free, bytes_used) df
   WHERE fs.tablespace_name(+) = df.tablespace_name
GROUP BY df.tablespace_name, fs.BYTES, df.bytes_free, df.bytes_used
ORDER BY 4 