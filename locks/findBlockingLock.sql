select dbs.inst_id
      ,dbs.sid holding_sid
      ,dbs.serial# holding_serial#
      ,dbs.username holding_user
      ,dbs.machine blocking_machine
      ,(select count(sid) from gv$session where blocking_session = dbs.sid and inst_id=dbs.inst_id) sessions_blocked
      ,dbs.sql_id holding_sql_id
      ,dbs.wait_class holding_class
      ,dbs.event holding_event
      ,dbs.seconds_in_wait holding_secs
      ,dws.sid waiting_sid
      ,dws.serial# waiting_serial#
      ,dws.username waiting_user
      ,dws.sql_id waiting_sql_id
      ,dws.wait_class waiting_class
      ,dws.event waiting_event
      ,dws.seconds_in_wait waiting_secs 
from gv$session dbs
    ,gv$session dws 
where dws.blocking_session = dbs.sid
and   dws.inst_id=dbs.inst_id 
order by dbs.sid, dws.seconds_in_wait desc;