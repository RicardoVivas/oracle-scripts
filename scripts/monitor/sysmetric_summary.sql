-- Copied from http://www.oracle.com/technology/pub/articles/schumacher_analysis.html
--
--The Oracle Database 10g V$SYSMETRIC view contains several excellent response-time metrics, 
--two of which are the Database Wait Time Ratio and Database CPU Time Ratio. 
--The query below shows the latest snapshot of these two statistics, which help you determine if your database is 
--currently experiencing a high percentage of waits/bottlenecks vs. smoothly running operations. 
--
--The Database CPU Time Ratio is calculated by dividing the amount of CPU expended in the database by 
--the amount of "database time," 
--which is defined as the time spent by the database on user-level calls (with instance background process activity being excluded). 
--High values (90-95+ percent) are good and indicate few wait/bottleneck actions, 
--but take this threshold only as a general rule of thumb because every system is different. 
--
select METRIC_NAME, VALUE from SYS.V_$SYSMETRIC where METRIC_NAME IN ('Database CPU Time Ratio', 'Database Wait Time Ratio') AND INTSIZE_CSEC = (select max(INTSIZE_CSEC) from SYS.V_$SYSMETRIC); 

--You can also take a quick look over the last hour to see if the database has experienced any dips in overall performance by using this query:
select  end_time, value from    sys.v_$sysmetric_history where   metric_name = 'Database CPU Time Ratio' order by 1 desc;


--The next question DBAs pose at the system level involves the average level of response time that their user community 
--is experiencing. (Prior to Oracle Database 10g this type of data was difficult to capture, but not anymore.) 
--The query shown above that interrogates the V$SYSMETRIC_SUMMARY view tells us what we need to know. 
--
--DBA can check the Response Time Per Txn and SQL Service Response Time metrics to see if a database issue exists. 
--For example, the statistics shown above report that the maximum response time per user transaction has been 
--only .28 second, with the average response time being a blazing .08 second. Oracle certainly wouldn't be to blame in this case.

select  CASE METRIC_NAME
            WHEN 'SQL Service Response Time' then 'SQL Service Response Time (secs)'
            WHEN 'Response Time Per Txn' then 'Response Time Per Txn (secs)'
            ELSE METRIC_NAME
            END METRIC_NAME,
		CASE METRIC_NAME
            WHEN 'SQL Service Response Time' then ROUND((MINVAL / 100),2)
            WHEN 'Response Time Per Txn' then ROUND((MINVAL / 100),2)
            ELSE MINVAL
            END MININUM,
		CASE METRIC_NAME
            WHEN 'SQL Service Response Time' then ROUND((MAXVAL / 100),2)
            WHEN 'Response Time Per Txn' then ROUND((MAXVAL / 100),2)
            ELSE MAXVAL
            END MAXIMUM,
		CASE METRIC_NAME
            WHEN 'SQL Service Response Time' then ROUND((AVERAGE / 100),2)
            WHEN 'Response Time Per Txn' then ROUND((AVERAGE / 100),2)
            ELSE AVERAGE
            END AVERAGE
from    SYS.V_$SYSMETRIC_SUMMARY 
where   METRIC_NAME in ('CPU Usage Per Sec',
                      'CPU Usage Per Txn',
                      'Database CPU Time Ratio',
                      'Database Wait Time Ratio',
                      'Executions Per Sec',
                      'Executions Per Txn',
                      'Response Time Per Txn',
                      'SQL Service Response Time',
                      'User Transaction Per Sec')
ORDER BY 1




--If, however, response times are longer than desired, the DBA will then want to know what types of user activities are 
--responsible for making the database work so hard. 
--Again, before Oracle Database 10g, this information was more difficult 
--to acquire, but now the answer is only a query away: 


select  case db_stat_name
            when 'parse time elapsed' then 
                'soft parse time'
            else db_stat_name
            end db_stat_name,
        case db_stat_name
            when 'sql execute elapsed time' then 
                time_secs - plsql_time 
            when 'parse time elapsed' then 
                time_secs - hard_parse_time
            else time_secs
            end time_secs,
        case db_stat_name
            when 'sql execute elapsed time' then 
                round(100 * (time_secs - plsql_time) / db_time,2)
            when 'parse time elapsed' then 
                round(100 * (time_secs - hard_parse_time) / db_time,2)  
            else round(100 * time_secs / db_time,2)  
            end pct_time
from
(select stat_name db_stat_name,
        round((value / 1000000),3) time_secs
    from sys.v_$sys_time_model
    where stat_name not in('DB time','background elapsed time',
                            'background cpu time','DB CPU')),
(select round((value / 1000000),3) db_time 
    from sys.v_$sys_time_model 
    where stat_name = 'DB time'),
(select round((value / 1000000),3) plsql_time 
    from sys.v_$sys_time_model 
    where stat_name = 'PL/SQL execution elapsed time'),
(select round((value / 1000000),3) hard_parse_time 
    from sys.v_$sys_time_model 
    where stat_name = 'hard parse elapsed time')
order by 2 desc;


