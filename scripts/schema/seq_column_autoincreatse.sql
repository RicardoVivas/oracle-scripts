
create or replace trigger crer_autonumber
before insert on crer for each row
begin
    if :new.id is null then
        select crer_seq.nextval into :new.id from dual;
    end if;
end;
/
