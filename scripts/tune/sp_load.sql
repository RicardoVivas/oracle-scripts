declare cnt number; 
BEGIN 
cnt:=DBMS_SPM.LOAD_PLANS_FROM_SQLSET(sqlset_name => 'TUNING SET FOR SQL BASELINE',sqlset_owner => 'SYSAS'); 
END;