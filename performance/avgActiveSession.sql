-- Gives average active session (like OEM) for all database instances
-- based on 1 minute interval from gv$active_session_history

select inst_id
      ,count(*)  DB_TIME
      ,round(count(*) / (60),2) Avg_Active_Session
      ,rpad('*',round(count(*) / (60),2),'*') LATENCY_GRAPH 
from       gv$active_session_history
where      session_type = 'FOREGROUND'
and sample_time > (sysdate -  1/1440)
group by inst_id;