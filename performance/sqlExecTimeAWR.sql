select inst_id
      ,user_id
      ,sql_id
      ,sql_plan_hash_value
      ,sql_Exec_id
      ,sql_exec_start
      ,MAX_EXEC_TIME
      ,MAX_EXEC_TIME - sql_exec_start as "EXEC_TIME"
    from
      (
select distinct instance_number as "INST_ID"
       ,user_id
       ,sql_id
       ,sql_plan_hash_value
       ,sql_exec_id
       ,sql_exec_start
       ,max(sample_time) over (partition by instance_number,user_id,sql_id,sql_exec_start) as "MAX_EXEC_TIME"
from dba_hist_active_sess_history 
where 1=1
and user_id=736
--and sql_id = 
and sql_exec_start is not null
)
order by 7 desc;