--This script is isefull to get over issues in Oracle AQ using pl/sql subscriber 
--with notification active. In that scenario, the notification acts as jobs, calling
--the procedure in chager of process the queue for every message queued

--set the pagesize for all querys executed on that session
set pagesize 1000;

--determine the process id of the related process referencing the relevant scheduler view
select p.spid, p.program, rj.job_name, sj.job_action 
  from dba_scheduler_jobs sj, 
       dba_scheduler_running_jobs rj, 
	   v$session s, 
	   v$process p 
 where sj.job_name = rj.job_name 
   and rj.session_id = s.sid 
   and s.paddr = p.addr 
   and lower(sj.job_action) like '%register_driver%';

-- statistics and and any errors
select * from gv$subscr_registration_stats;

-- currently running jobs ; more detail from the above
select * from dba_scheduler_running_jobs where lower(job_name) like 'aq$_plsql_ntfn%';

-- jobs defined relating to notification ; both give the same results :
select * from dba_scheduler_jobs where lower(job_name) like 'aq$_plsql_ntfn%';
select * from dba_scheduler_jobs where lower(job_action) = 'dbms_aqadm_sys.register_driver';

-- scheduler job log activity wrt plsql notification
select * from dba_scheduler_job_log where lower(job_name) like 'aq$_plsql_ntfn%' order by log_date desc;

--Determine the extent of the issue by finding how many messages are in the notification queue but not in the usercreated
--application queue. Use the following as a basis to determine the scale of the inconsistency modifying as
--appropriate for your environment
select msgid notify_msgid, to_char(n.enq_time,'DD-MON-YYYY hh24:mi:ss'), n.user_data.msg_id app_msgid,
       n.user_data.queue_name qname, nvl(utl_raw.cast_to_varchar2(n.user_data.payload),'null') payload
  from sys.aq_srvntfn_table_1 n
 where n.user_data.msg_id in 
	   ( select n.user_data.msg_id msgid from sys.aq_srvntfn_table_1 n
		 minus select msgid from SCHEMANAME.QUEUE_TABLE_NAME )
   and n.user_data.queue_name = '"SCHEMANAME"."QUEUE_NAME"';

--For those msgids returned, manually dequeue these messages by specifying the message id from the notification
--queue : AQ_SRVNTFN_TABLE_Q (in versions below 11.2) or AQ_SRVNTFN_TABLE_Q_<N> (in versions starting
--11.2). In doing this, we are removing the message in the notification queue which is not in the Application queue.
set serveroutput on
GRANT EXECUTE ON aq$_srvntfn_message TO ADMDEC;
GRANT ENQUEUE ANY QUEUE TO USERNAME;
GRANT DEQUEUE ANY QUEUE TO USERNAME;
GRANT EXECUTE ON dbms_aq TO USERNAME;
GRANT EXECUTE ON DBMS_AQADM TO USERNAME;

set serveroutput on
declare
	enqueue_options dbms_aq.enqueue_options_t;
	message_properties dbms_aq.message_properties_t;
	dequeue_options dbms_aq.dequeue_options_t;
	message_handle raw(16);
	mes raw(1000); -- dbms_aq.aq$_srvntfn_message;
begin
	dequeue_options.wait 			:= dbms_aq.no_wait;
	dequeue_options.consumer_name 	:= 'SUBSCRIBER_NAME'; 					-- <<< supply subscriber name
	dequeue_options.msgid 			:= '789BF85EBAA9402AE05400144FFA1C0D'; 	-- <<< supply mesage id
	
	dbms_aq.dequeue(
		queue_name => 'SYS.AQ_SRVNTFN_TABLE_Q_1', 							-- <<< as appropriate
		dequeue_options => dequeue_options,
		message_properties => message_properties,
		payload => mes,
		msgid => message_handle);
		
	dbms_output.put_line('removed: ' || message_handle);
	
	commit;
end;
/