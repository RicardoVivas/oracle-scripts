select address, hash_value from v$sql where sql_id = '0k8522rmdzg4k'
select substr(sql_text,1,30) Text,address,hash_value,KEPT_VERSIONS from v$sql where sql_id = '0k8522rmdzg4k'
exec DBMS_SHARED_POOL.KEEP('00000002F5DBB038,3873422482','C');
select distinct name from v$db_object_cache where kept='YES'



> select sysdate, fetches,executions,buffer_gets  from v$sql where sql_id = '0k8522rmdzg4k' and last_active_time > sysdate - 0.25
 
SYSDATE                   FETCHES                EXECUTIONS             BUFFER_GETS            
------------------------- ---------------------- ---------------------- ---------------------- 
26-MAR-2013 10.39.09      105301                 28375                  183066                 

------------------------- ---------------------- ---------------------- ---------------------- 
26-MAR-2013 10.40.15      105325                 28381                  183106                 

------------------------- ---------------------- ---------------------- ---------------------- 
26-MAR-2013 10.42.06      105333                 28385                  183126                 

------------------------- ---------------------- ---------------------- ---------------------- 
26-MAR-2013 15.40.29      111901                 29919                  193682                 68222190000            110958998685 

select component, sum(current_size)/1024/1024 current_mb, sum(max_size)/1024/1024 max_mb from v$memory_dynamic_components  group by cube(component)  order by 2;

alter system set db_keep_cache_size=100m



select sysdate, parse_calls, buffer_gets, rows_processed,fetches, executions, cpu_time, elapsed_time, concurrency_wait_time from v$sqlstats where sql_id = '0k8522rmdzg4k'
 
SYSDATE                   PARSE_CALLS            BUFFER_GETS            ROWS_PROCESSED         FETCHES                EXECUTIONS             CPU_TIME               ELAPSED_TIME           CONCURRENCY_WAIT_TIME  
------------------------- ---------------------- ---------------------- ---------------------- ---------------------- ---------------------- ---------------------- ---------------------- ---------------------- 
26-MAR-2013 17.06.20      38450                  252743                 110908                 148509                 38450                  78884750000            167313966254           77328200424            

26-MAR-2013 17.07.16      38450                  252743                 110908                 148509                 38450                  78884750000            167313966254           77328200424            

26-MAR-2013 17.09.09      38451                  252750                 110911                 148513                 38451                  78887300000            167316521642           77328200424            

26-MAR-2013 17.20.04      38485                  253023                 111075                 148710                 38485                  78966500000            167420454317           77339759682            



http://www.usn-it.de/wp-content/uploads/2012/04/2012_893_Klier_doc_v2.pdf

