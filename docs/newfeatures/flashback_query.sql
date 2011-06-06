SQL> desc my_table
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 CHANNELID                                          NUMBER
 SGWID                                              VARCHAR2(50)
 SERVICETYPE                                        VARCHAR2(50)
 SPNUMBER                                           VARCHAR2(50)
 CMD                                                VARCHAR2(50)
 CREATETIME                                         DATE
 MORE                                               VARCHAR2(500)



---From timestamp -------------------------

select count(*) from my_table as of timestamp to_date('08/03/10 13:10:00','dd/mm/yy hh24:mi:ss');
select count(*) from my_table as of scn 708600000;           


---From SCN -------------------------------

select dbms_flashback.get_system_change_number from dual;
select current_scn, systimestamp from v$database
select scn_to_timestamp(708000000) from dual;
select timestamp_to_scn(systimestamp) from dual;

--SQL>create table lm_temp as select * from my_table as of scn 708000000;


-- Version query ----------------------------------------------------
select 
versions_startscn, versions_starttime, 
versions_endscn,   versions_endtime, 
versions_xid, versions_operation , 
id 
from uow_flashback_table 
versions between  scn 5850900 and  5851911;




