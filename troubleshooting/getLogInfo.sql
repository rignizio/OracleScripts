-- Get log information
select l.thread#
      ,l.group#
      ,l.sequence#
      ,l.bytes/1024/1024 "LOG_SIZE"
      ,lf.MEMBER "LOG_FILE_NAME"
      ,l.archived
      ,l.status
      ,l.first_time 
from v$log l, v$logfile lf
where lf.group# = l.group# 
order by thread#,group#;


