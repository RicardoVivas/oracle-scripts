create or replace
function dummy
return DBMS_DEBUG_VC2COLL
PIPELINED -- NOTE the pipelined keyword
is
begin
pipe row (to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS' ));
dbms_lock.sleep(15);
pipe row (to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS' ));
return;
end;
/

set arraysize 1
select * from table(dummy());