-- This will get the running, rolling avg of archive log generation
-- over last three/seven days
select dttm
      ,arch_Size
      ,sum(arch_size) over (order by dttm asc) "Running"
      ,sum(arch_Size) over (order by dttm asc range 3 preceding) "LAST_3"
      ,sum(arch_Size) over (order by dttm asc range 7 preceding) "LAST_7"
from(
select trunc(first_Time) "DTTM"
      ,round(sum(round((blocks*block_Size)/1024/1024)/1024)) "ARCH_SIZE"
from v$archived_log
group by trunc(first_time)
order by 1
)