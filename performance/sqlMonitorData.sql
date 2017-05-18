-- Time is in seconds

select sm.inst_id
      ,sm.sid
      ,sm.key
      ,sm.status
      ,sm.sql_id
      ,sm.sql_plan_hash_value
      ,sm.username
      ,sm.service_name
      ,sm.sql_exec_start
      ,round((sm.last_refresh_time-sm.sql_exec_start)*24*60*60,2) TOT_ELA_SEC -- seconds
      ,round((sm.elapsed_time/1000000),2) DB_ELA_SEC -- seconds
      ,spm.output_rows
      ,sm.px_maxdop
      ,round((sm.cpu_time/1000000),2) CPU_TIME
      ,round((sm.USER_IO_WAIT_TIME/1000000),2) IO_WAIT_TIME
      ,round((sm.CLUSTER_WAIT_TIME/1000000),2) CLUSTER_WAIT_TIME
      ,sm.buffer_gets
      ,sm.disk_reads
      ,sm.sql_text
      ,xmltype(sm.binds_xml)
from gv$sql_monitor SM
    ,gv$sql_plan_monitor SPM
where 1=1
and SM.inst_id=SPM.INST_ID
and SM.key=SPM.KEY
and SM.SQL_ID=SPM.SQL_ID
and SPM.plan_line_id=0
and SM.status <> 'EXECUTING'
and SM.sql_id in ('a1nx8mxgj2pdd')
--and sm.username like 'OPS$KALLISON'
order by sql_exec_start desc; 

