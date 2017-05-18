set linesize 1000
col name format a15
select d.group_number 
      ,d.name
	  ,o.inst_id
	  ,o.operation
	  ,o.state
	  ,o.power
	  ,o.actual
	  ,o.sofar
	  ,o.est_work
	  ,o.est_rate
	  ,o.est_minutes
	 -- ,o.error_code
from v$asm_diskgroup d
    ,gv$asm_operation o
where d.group_number=o.group_number
and o.state='RUN';
