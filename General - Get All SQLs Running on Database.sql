--This script get all SQLs running on database
--Useful to get expensive querys on database

select s.username, s.sid, s.serial#, s.last_call_et/60 mins_running, 
       q.sharable_mem, q.disk_reads, q.cpu_time, q.sql_fulltext
  from v$session s 
  join v$sql q on s.sql_address = q.address
 where status='ACTIVE'
   and type <>'BACKGROUND'
   and last_call_et > 60
 order by sid, serial#