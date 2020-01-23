-- Use this to verify what instances TEMP cache's

select inst_id
      ,tablespace_name
      ,file_id
      ,extents_cached
      ,extents_used
      ,bytes_cached/1024/1024/1024 BYTES_C_GB
      ,bytes_used/1024/1024/1024 BYTES_U_GB
from gv$temp_extent_pool 
order by inst_id,extents_cached ;