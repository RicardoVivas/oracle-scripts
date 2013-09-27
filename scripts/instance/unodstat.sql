-- pay attention to column SSOLDERRCNT, TUNED_UNDORETENTION, UNXPBLKREUCNT
select * from V$UNDOSTAT order by begin_time desc;