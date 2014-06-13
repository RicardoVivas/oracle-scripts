create or replace  procedure list_tables (schema_name in varchar2) 
IS
cursor c1 is select * from dba_tables 
where owner = upper(schema_name);
begin
	for tname in c1 loop
	 dbms_output.put_line(tname.table_name);
	end loop;
end;
/
