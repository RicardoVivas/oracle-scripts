begin

alter session set events '10046 trace name context forever, level 8';

for i in 0 .. 10 loop
 
select /*+ connect_by_filtering */ privilege#,level from sysauth$ connect by
grantee#=prior privilege# and privilege#>0 start with grantee#=53 and
privilege#>0
;
select /*+ connect_by_filtering */ privilege#,level from sysauth$ connect by
grantee#=prior privilege# and privilege#>0 start with grantee#=53 and
privilege#>0
;
select /*+ connect_by_filtering */ privilege#,level from sysauth$ connect by
grantee#=prior privilege# and privilege#>0 start with grantee#=53 and
privilege#>0
;
select /*+ connect_by_filtering */ privilege#,level from sysauth$ connect by
grantee#=prior privilege# and privilege#>0 start with grantee#=53 and
privilege#>0
;
select /*+ connect_by_filtering */ privilege#,level from sysauth$ connect by
grantee#=prior privilege# and privilege#>0 start with grantee#=53 and
privilege#>0
;
 
dbms_lock.sleep(60);
 
end loop;

alter session set events '10046 trace name context off';

end;