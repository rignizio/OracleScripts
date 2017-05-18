
select to_char((SNAP.end_interval_time),'DD-MON-YYYY DY HH24:MI') END_DATE
      ,SQLSTAT.snap_id
      ,SQLSTAT.instance_number INST_ID
	  ,SQLSTAT.sql_id
	  ,SQLSTAT.plan_hash_value PL_HASH_VALUE
	  ,SQLSTAT.PARSING_SCHEMA_NAME SCHEMA
	  ,trunc((SQLSTAT.elapsed_time_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end ))/1000000,2) ELA_TIME
	  ,trunc((SQLSTAT.cpu_time_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end ))/1000000,2) cpu_time_delta
	  ,trunc((SQLSTAT.iowait_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end ))/1000000,2) iowait_delta
	  ,trunc((SQLSTAT.clwait_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end ))/1000000,2) clwait_delta
	  ,SQLSTAT.executions_delta executions
	  ,case SQLSTAT.rows_processed_delta 
            when 0 then 0
            else trunc((SQLSTAT.rows_processed_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) 
            end rows_processed
	  ,trunc((SQLSTAT.disk_reads_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) PIO_PER_EXEC
	  ,trunc((SQLSTAT.buffer_gets_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) LIO_PER_EXEC
	  ,SQL_PROFILE
	  ,FORCE_MATCHING_SIGNATURE
	  ,trunc((SQLSTAT.apwait_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) apwait_delta
	  ,trunc((SQLSTAT.ccwait_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) ccwait_delta
	  ,trunc((SQLSTAT.direct_writes_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) direct_writes_delta
	  ,trunc((SQLSTAT.plsexec_time_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) plsexec_time_delta
	  ,trunc((SQLSTAT.fetches_delta/(case executions_delta when 0 then 1 else executions_delta end )),0) fetches_delta
	  ,trunc((SQLSTAT.disk_reads_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) +
       trunc((SQLSTAT.buffer_gets_delta/(case SQLSTAT.executions_delta when 0 then 1 else SQLSTAT.executions_delta end )),0) total_reads_per_execution
 from sys.DBA_HIST_SQLSTAT SQLSTAT,sys.DBA_HIST_SNAPSHOT SNAP
where   1=1
 and SQLSTAT.snap_id=SNAP.snap_id 
 and SQLSTAT.instance_number=SNAP.instance_number
-- and trunc(end_interval_time) in (to_date('15-mar-11','dd-mon-yy'),to_date('22-mar-11','dd-mon-yy'))
and SQLSTAT.sql_id in('9szu629r54z2u')
 and executions_delta > 0
-- and parsing_schema_name<>'SYS'
and SNAP.dbid=SQLSTAT.dbid
order by SQLSTAT.dbid,SNAP.end_interval_time