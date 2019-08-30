--This script get all sessions, all loked sessions and 
--an example on how to kill that session

--get all session active on database
SELECT * FROM V$SESSION;

--get loked sessions on database
select s.sid
      ,s.serial#
      ,s.username
      ,s.machine
      ,s.status
      ,s.lockwait
      ,t.used_ublk
      ,t.used_urec
      ,t.start_time
from v$transaction t
inner join v$session s on t.addr = s.taddr;

--kill one specific session on database
ALTER SYSTEM KILL SESSION '614,23281' IMMEDIATE; 
