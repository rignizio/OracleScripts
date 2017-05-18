-- 
-- Run this to see who is comsuming the temp space 
-- 
select se.inst_id
      ,se.sid
      ,se.username
      ,se.sql_id
      ,tu.tablespace
      ,(sum(tu.blocks)*8192)/1024/1024 "TOATAL_TEMP_USED_MB"
      ,sum((sum(tu.blocks)*8192)/1024/1024) over (partition by tu.tablespace order by tu.tablespace,sum(tu.blocks)*8192,se.inst_id,se.sql_id,se.username,se.sid) "RUNNING_TOTAL_MB"
from
gv$tempseg_usage tu,
gv$session se
where
tu.inst_id=se.inst_id and
tu.session_addr=se.saddr and
tu.session_num=se.serial#
group by se.inst_id,se.sid,se.username,se.sql_id,tu.tablespace;