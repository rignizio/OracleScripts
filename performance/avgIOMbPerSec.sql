-- 
-- Script for identifiying I/O MB Per Second
-- 

select ash.END_TIME
      ,ash.metric_name
      ,ash.inst_id
      ,round(ash.value,2) MB_PER_SEC
      ,rpad('*',round(ash.value,1),'*') LATENCY_GRAPH 
from GV$SYSMETRIC_HISTORY ASH
where 1=1
and metric_name='I/O Megabytes per Second'
order by end_time desc,inst_id;

select ash.snap_id
      ,ash.instance_number
      ,ash.end_time
      ,ash.metric_name
      ,round(ash.value,2)
      ,rpad('*',round(ash.value,1),'*') LATENCY_GRAPH 
from 
DBA_HIST_SYSMETRIC_HISTORY ASH,dba_hist_snapshot SNAP
where 1=1
and  ash.snap_id=snap.snap_id
and ash.dbid=snap.dbid
and ash.instance_number=snap.instance_number
and snap.end_interval_time > sysdate - 1
and metric_name='I/O Megabytes per Second'
order by end_time;