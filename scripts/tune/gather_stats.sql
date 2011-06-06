execute dbms_stats.gather_schema_stats(ownname=>'&schema', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=> 'for all indexed columns size 1',cascade => TRUE);
execute dbms_stats.gather_schema_stats(ownname=>'&schema', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=> 'for all  columns size 1',cascade => TRUE);

execute dbms_stats.gather_table_stats(ownname=>'&schema', tabname=>'&table_name',estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=> 'for all indexed columns size 1',cascade => TRUE);

-- gather partition stats
execute dbms_stats.gather_table_stats(ownname=>'&schema', tabname=>'&table_name',partname=>'&partition_name',estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=> 'for all columns size 1',cascade => TRUE);

execute dbms_stats.gather_index_stats(ownname=>'&schema', indname=>'&index_name')

execute dbms_stats.create_stat_table(ownname => '&stats_table_owner', stattab => 'statstab')
execute dbms_stats.export_table_stats(ownname => '&owner', tabname => '&tablename', partname => null, stattab => 'statstab', statid => '&statsID',statown => '&statTableOwner')
execute dbms_stats.import_table_stats(ownname => '&owner', tabname => '&tablename', partname => null, stattab => 'statstab', statid => '&statsID',statown => '&statTableOwner')
execute dbms_stats.delete_table_stats(ownname => '&owner', tabname => '&tablename')



ANALYZE TABLE employees COMPUTE STATISTICS; 
ANALYZE INDEX employees_pk COMPUTE STATISTICS



-- gather system statistics
execute dbms_stats.create_stat_table('system','system_statistics','tools');
alter system set job_queue_processes=2;
 
 -- then connect as system
execute dbms_stats.gather_system_stats(interval=>360,stattab=>'system_statistics',statid=>'06-05-05');

 
If stattab is not specified, system stats are stored  in aux_stats$ view;

execute dbms_stats.gather_system_stats(gathering_mode=>'START');
execute dbms_stats.gather_system_stats(gathering_mode=>'STOP');
execute dbms_stats.delete_system_stats(NULL, NULL,NULL);




select /*+ gather_plan_statistics */ ... from ... ;
select * from table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));


