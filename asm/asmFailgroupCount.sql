set pagesize 70
col failgroup format a15
col name format a15
select D.group_number
      ,DG.name
      ,D.failgroup
	  ,D.mode_status
	  ,count(*) 
from v$asm_disk D
    ,v$asm_diskgroup DG
where d.group_number=dg.group_number
group by d.group_number
        ,dg.name
		,d.failgroup
		,d.mode_status;