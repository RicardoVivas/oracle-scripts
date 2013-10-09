
set arraysize 1
select * from table(sql_stats); 

create or replace type piped_output_table as table of varchar2(400);
/

create or replace function sql_stats 
  return piped_output_table 
  pipelined IS
 
  text varchar2(4000); 
  idx number := 10;
  msg varchar2(400);

  exec_num_pre  number := 0;
  disk_reads_pre  number;
  buffer_gets_pre number;
  rows_processed_pre number;
  elapsed_time_pre number;
  last_active_pre date;

  exec_num  number;
  disk_reads  number;
  buffer_gets number;
  rows_processed number;
  elapsed_time number;
  last_active date;
  
  sleep_time number := 5;

  cursor c1 is 
    select last_active_time, executions, disk_reads, buffer_gets, rows_processed, elapsed_time from v$sqlstats where sql_id= '50gka276fq13q';
    
begin
 
 pipe row('exec/s disk_r/e  buffer/e rows_processed/e elapsed_ms/e'  );
 

 for idx in 1..5 loop
   
   open c1;
   fetch c1 into last_active, exec_num, disk_reads, buffer_gets, rows_processed, elapsed_time;
   close c1;
   
   if idx > 1 then
     msg := round((exec_num - exec_num_pre)/sleep_time)  || '       '   
         || round((disk_reads - disk_reads_pre)/(exec_num - exec_num_pre))  || '          '
         || round((buffer_gets - buffer_gets_pre)/(exec_num - exec_num_pre))  || '          '
         || round((rows_processed - rows_processed_pre)/(exec_num - exec_num_pre))  || '          '
         || round((elapsed_time - elapsed_time_pre)/(exec_num - exec_num_pre)/1000)  ;
     pipe row(msg);
   end if;
   
   exec_num_pre := exec_num;
   disk_reads_pre := disk_reads;
   buffer_gets_pre := buffer_gets;
   rows_processed_pre := rows_processed;
   elapsed_time_pre := elapsed_time;
   last_active_pre  := last_active;
   
   dbms_lock.sleep (sleep_time); 
   
 end loop;
 return;
end;
/

