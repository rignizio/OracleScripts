select inst_id
      ,sql_id
      ,PLAN_HASH_VALUE
      ,EXACT_MATCHING_SIGNATURE
      ,CHILD_NUMBER
      ,round((elapsed_time/case executions when 0 then 1 else executions end)/1000000,2) AVG_ELAPSED
      ,round(buffer_Gets/(case rows_processed when 0 then 1 else rows_processed end),2) GETS_PER_ROW
      ,EXECUTIONS
      ,sql_text
      ,FETCHES
      ,FIRST_LOAD_TIME
      ,PARSE_CALLS
      ,DISK_READS
      ,DIRECT_WRITES
      ,BUFFER_GETS
      ,CLUSTER_WAIT_TIME
      ,USER_IO_WAIT_TIME
      ,ROWS_PROCESSED
      ,OPTIMIZER_MODE
      ,OPTIMIZER_COST
      ,PARSING_SCHEMA_NAME
      ,SERVICE
      ,MODULE
      ,CPU_TIME
      ,ELAPSED_TIME
      ,IS_OBSOLETE
      ,IS_BIND_SENSITIVE
      ,IS_BIND_AWARE
      ,IS_SHAREABLE
      ,SQL_PROFILE
      ,SQL_PLAN_BASELINE
      ,IO_CELL_OFFLOAD_ELIGIBLE_BYTES
      ,IO_INTERCONNECT_BYTES
      ,PHYSICAL_READ_REQUESTS
      ,PHYSICAL_READ_BYTES
      ,PHYSICAL_WRITE_REQUESTS
      ,PHYSICAL_WRITE_BYTES
      ,OPTIMIZED_PHY_READ_REQUESTS
      ,IO_CELL_UNCOMPRESSED_BYTES
      ,IO_CELL_OFFLOAD_RETURNED_BYTES
      ,sql_fulltext
from gv$sql 
where 1=1
--and lower(sql_text) like 'insert%tmp_fact_clp_wcpt_q1_j%'
--and sql_id = 'fgvq0bcyy7uyq'
and sql_text not like '%gv$sql%' 
order by sql_id,child_number;