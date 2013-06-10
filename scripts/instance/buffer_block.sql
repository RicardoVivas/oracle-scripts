select
count(*)
, name
, file#
, dbablk
, hladdr
from x$bh bh
, obj$ o
where
o.obj#(+)=bh.obj and
hladdr in
(
select ltrim(to_char(p1,'XXXXXXXXXX') )
from v$active_session_history
where event like 'latch: cache%'
group by p1
)
group by name,file#, dbablk, hladdr
having count(*) > 1
order by count(*);