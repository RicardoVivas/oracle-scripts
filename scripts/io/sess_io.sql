clear
drop table sesstats_base;
drop table sesstats_delta;

create table sesstats_base as 
select  phyr.sid, phyr.username, phyr.phy_reads, phyw.phy_writes, sysdate logtime  from
(select
     b.sid sid,
     nvl(b.username,b.program) username,
     sum(value) phy_reads
 from
     sys.v_$sesstat a,
     sys.v_$session b,
     sys.v_$statname c     
 where
      a.statistic#=c.statistic# and      
      b.sid=a.sid and
      c.name in ('physical reads',
                 'physical reads direct',
                 'physical reads direct (lob)')
group by      b.sid, nvl(b.username, b.program)) phyr,
(select
     b.sid sid,
      nvl(b.username,b.program) username,
     sum(value) phy_writes
 from
     sys.v_$sesstat a,
     sys.v_$session b,
     sys.v_$statname c      
 where
      a.statistic#=c.statistic# and     
      b.sid=a.sid and
      c.name in ('physical writes',
                 'physical writes direct',
                 'physical writes direct (lob)')
group by      b.sid, nvl(b.username, b.program)) phyw
where 
  phyr.sid = phyw.sid;
  
 
pause wait several seconds before hit any key ...


create table sesstats_delta as 
select  phyr.sid, phyr.username, phyr.phy_reads, phyw.phy_writes, sysdate logtime  from
(select
     b.sid sid,
     nvl(b.username,b.program) username,
     sum(value) phy_reads
 from
     sys.v_$sesstat a,
     sys.v_$session b,
     sys.v_$statname c     
 where
      a.statistic#=c.statistic# and      
      b.sid=a.sid and
      c.name in ('physical reads',
                 'physical reads direct',
                 'physical reads direct (lob)')
group by      b.sid, nvl(b.username, b.program)) phyr,
(select
     b.sid sid,
      nvl(b.username,b.program) username,
     sum(value) phy_writes
 from
     sys.v_$sesstat a,
     sys.v_$session b,
     sys.v_$statname c      
 where
      a.statistic#=c.statistic# and     
      b.sid=a.sid and
      c.name in ('physical writes',
                 'physical writes direct',
                 'physical writes direct (lob)')
group by      b.sid, nvl(b.username, b.program)) phyw
where 
  phyr.sid = phyw.sid;  
  

select 
 b.username,
 b.sid,
 (b.phy_reads  - a.phy_reads) phyr,
 round((b.phy_reads  - a.phy_reads)/((b.logtime - a.logtime) * 24 * 3600), 1) phyr_per_sec,
 (b.phy_writes - a.phy_writes) phyw,
 round((b.phy_writes - a.phy_writes)/((b.logtime - a.logtime) * 24 * 3600), 1) phyw_per_sec,
 ((b.phy_reads  - a.phy_reads) + (b.phy_writes - a.phy_writes) ) total_io,
 round((b.logtime - a.logtime) * 24 * 3600)  "logtime(seconds)"
from 
sesstats_base a, 
sesstats_delta b 
where a.sid = b.sid 
 and (b.phy_reads  - a.phy_reads) + (b.phy_writes - a.phy_writes) > 0
order by 7  desc;