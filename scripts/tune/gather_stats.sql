execute dbms_stats.gather_schema_stats(ownname=>'&schema');
execute dbms_stats.gather_table_stats(ownname=>'&schema', tabname=>'&table_name');

-- gather partition stats
execute dbms_stats.gather_table_stats(ownname=>'&schema', tabname=>'&table_name',partname=>'&partition_name');
execute dbms_stats.gather_index_stats(ownname=>'&schema', indname=>'&index_name')

execute dbms_stats.create_stat_table(ownname => '&stats_table_owner', stattab => 'statstab')
execute dbms_stats.export_table_stats(ownname => '&owner', tabname => '&tablename', partname => null, stattab => 'statstab', statid => '&statsID',statown => '&statTableOwner')
execute dbms_stats.import_table_stats(ownname => '&owner', tabname => '&tablename', partname => null, stattab => 'statstab', statid => '&statsID',statown => '&statTableOwner')
execute dbms_stats.delete_table_stats(ownname => '&owner', tabname => '&tablename')



-- Gather system statistics into a table
execute dbms_stats.create_stat_table('system','system_statistics','tools');
alter system set job_queue_processes=2;
 
 -- then connect as system
execute dbms_stats.gather_system_stats(interval=>360,stattab=>'system_statistics',statid=>'06-05-05');

 
-- If stattab is not specified, system stats are stored  in aux_stats$ view;

-- Manually start and stop to sample a representative time (several hours) of system activity.
execute dbms_stats.gather_system_stats(gathering_mode=>'START');
execute dbms_stats.gather_system_stats(gathering_mode=>'STOP');

-- Sample from now until a specific number of minutes.
execute DBMS_STATS.gather_system_stats('interval', interval => 180); 

-- Delete all workload stats and replace previously gathered noworkload stats with the default values
execute dbms_stats.delete_system_stats(NULL, NULL,NULL);

select * from SYS.aux_stats$

select /*+ gather_plan_statistics */ ... from ... ;
select * from table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));



-- Fixed Object statistics must be manually gathered. They are not created or maintained by the automatic statistics gathering job. 
-- https://blogs.oracle.com/optimizer/entry/fixed_objects_statistics_and_why
BEGIN
DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
END;

