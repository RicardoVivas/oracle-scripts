select  substr(d.name, 1, 50), s.phyrds,s.phywrts,s.avgiotim,s.miniotim,s.maxiowtm, s.maxiortm from v$datafile d, v$filestat s where s.file# =d.file#
union 
select  substr(t.name, 1, 50), s.phyrds,s.phywrts,s.avgiotim,s.miniotim,s.maxiowtm, s.maxiortm from v$tempfile t, v$filestat s where s.file# = t.file# 
order by 2 desc