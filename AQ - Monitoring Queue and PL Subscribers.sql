--This scritpt is usefull to monitoring Oracle AQ when you
--use PL subscribers to consume the queue

--get all consumers registred on Oracle AQ
SELECT * FROM DBA_QUEUE_SUBSCRIBERS;

--get all queue tables granted to current user
SELECT * FROM ALL_QUEUE_TABLES;

--get all queues granted to current user
select * from ALL_QUEUES;

--get all subscrubers registered to specific queue
select * from USEREXAMPLE.AQ$EXAMPLE_QUEUE_TABLE_S;

--get all messanges on specific queue table
SELECT COUNT(*) QTD, MSG_STATE 
  FROM USEREXAMPLE.AQ$EXAMPLE_QUEUE_TABLE 
 GROUP BY MSG_STATE;

-- get all messages in queue table
SELECT msg_state, retry_count, COUNT(1) 
  FROM USEREXAMPLE.AQ$EXAMPLE_QUEUE_TABLE q 
 GROUP BY msg_state, retry_count;

-- queues with unprocessed messages (not always accurate)
SELECT dq.name, v.ready
  FROM gv$aq v, dba_queues dq
WHERE dq.qid = v.qid
   AND dq.name LIKE '%EXAMPLE%'
   AND waiting + ready + expired > 0
ORDER BY 1;

-- notification queue counts (not always accurate)
SELECT dq.name, v.*
  FROM gv$aq v, dba_queues dq
WHERE dq.qid = v.qid
ORDER BY 1;

-- job queue processes
SELECT *
  FROM dba_scheduler_jobs
WHERE job_name LIKE '%_PLSQL_NTFN%' or job_name LIKE '%_PLSQL_NTFN%'
ORDER BY 1,2;

-- notification queue count (always accurate)

SELECT COUNT(1)
  FROM sys.aq$aq_srvntfn_table_1 -- RAC: instance 2 (check for each instance)
WHERE queue LIKE 'AQ_SRVNTFN_TABLE_Q%'
   AND msg_state = 'READY';
   
-- check for running job queue processes
SELECT *
  FROM dba_scheduler_running_jobs
WHERE job_name LIKE  '%_PLSQL_NTFN%';   

-- notification (job queue) log
SELECT *
  FROM dba_scheduler_job_log
WHERE job_name LIKE '%_PLSQL_NTFN%'
   AND log_date > SYSDATE - 7
ORDER BY 1 DESC, 2 DESC;

-- notification (job queue) log details
SELECT *
  FROM dba_scheduler_job_run_details
WHERE job_name LIKE  '%_PLSQL_NTFN%'
ORDER BY log_id DESC;

-- check if consumer is registered
SELECT u.username, sr.subscription_name, sr.location_name
  FROM dba_subscr_registrations sr, dba_users u
WHERE u.user_id = sr.user#
   AND sr.subscription_name LIKE '%EXAMPLE%';