-- Gives average active session (like OEM) for all database instances and wait_class
-- based on 1 minute interval from gv$active_session_history

set linesize 100
col wait_class format a15
col LATENCY_GRAPH format a30

select inst_id
      ,CASE  WHEN WAIT_CLASS IS NULL THEN 'CPU' ELSE WAIT_CLASS END WAIT_CLASS
      ,count(*)  DB_TIME
      ,round(count(*) / (60),2) Avg_Active_Session
      ,rpad('*',round(count(*) / (60),2),'*') LATENCY_GRAPH 
from       gv$active_session_history
where      session_type = 'FOREGROUND'
and sample_time > (sysdate -  1/1440)
group by inst_id,CASE  WHEN WAIT_CLASS IS NULL THEN 'CPU' ELSE WAIT_CLASS END
order by inst_id,4 desc;