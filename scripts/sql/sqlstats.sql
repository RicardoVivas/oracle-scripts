set verify off

set serveroutput on

declare 
  idx number := 10;
  msg varchar2(2000);

  exec_num_pre  number := 0;
  disk_reads_pre  number;
  buffer_gets_pre number;
  rows_processed_pre number;
  elapsed_time_pre number;
  cpu_time_pre number;
  io_wait_pre number;
  phy_reads_bytes_pre number;
  phy_writes_bytes_pre number;
  
  exec_num  number;
  disk_reads  number;
  buffer_gets number;
  rows_processed number;
  elapsed_time number;
  cpu_time number;
  io_wait number;
  phy_reads_bytes number;
  phy_writes_bytes number;
  
  sleep_time number := 5;

  cursor c1 is 
    select executions,disk_reads,buffer_gets,rows_processed,elapsed_time,cpu_time, user_io_wait_time, physical_read_bytes,physical_write_bytes
               from v$sqlstats where sql_id= '&sql_id';
begin

 dbms_output.put_line('  exec/s  buffer/e  elapsed/e cpu/e, io_wait/e, phy_rb/e, phy_wb/e disk_r/e rows/e --- time in ms'  );
 
 for idx in 1..4 loop
   open c1;
   fetch c1 into  exec_num, disk_reads, buffer_gets, rows_processed,elapsed_time,cpu_time,io_wait,phy_reads_bytes,phy_writes_bytes;
   close c1;
   
   if idx > 1 then
     if ( exec_num - exec_num_pre ) = 0 then
       msg := 'No change in executions';
     else
     msg := to_char( (exec_num - exec_num_pre)/sleep_time,'9,999.9')  || '  '   
         || to_char( (buffer_gets - buffer_gets_pre)/(exec_num - exec_num_pre),'9,999')  || '  '
         || to_char( (elapsed_time - elapsed_time_pre)/(exec_num - exec_num_pre)/1000,'9,999.9') || '  '
         || to_char( (cpu_time - cpu_time_pre)/(exec_num - exec_num_pre)/1000,'9999.9') || '  '
         || to_char( (io_wait - io_wait_pre)/(exec_num - exec_num_pre)/1000,'9999.9') || '     '
         || to_char( (phy_reads_bytes - phy_reads_bytes_pre)/(exec_num - exec_num_pre),'999,999') || '  '
         || to_char( (phy_writes_bytes - phy_writes_bytes_pre)/(exec_num - exec_num_pre),'9,999') || '  '
         || to_char( (disk_reads - disk_reads_pre)/(exec_num - exec_num_pre),'9999.9')  || '  '
         || to_char( (rows_processed - rows_processed_pre)/(exec_num - exec_num_pre),'9,999.9');
     end if;
     dbms_output.put_line(msg);
   end if;
   
   exec_num_pre := exec_num;
   disk_reads_pre := disk_reads;
   buffer_gets_pre := buffer_gets;
   rows_processed_pre := rows_processed;
   elapsed_time_pre := elapsed_time;
   cpu_time_pre := cpu_time;
   io_wait_pre := io_wait;
   phy_reads_bytes_pre := phy_reads_bytes;
   phy_writes_bytes_pre := phy_writes_bytes;
   
   dbms_lock.sleep (sleep_time); 
   
 end loop;
end;
/
  
 