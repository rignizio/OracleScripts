col path format a20
col name format a40
col dg_name format a15
set linesize 1000
select inst_id
      ,group_number
	  ,(select name from v$asm_diskgroup d where d.group_number=ad.group_number) DG_NAME
	  ,path,header_status
	  ,mount_status
	  ,name
from gv$asm_disk AD
where mount_status <> 'CACHED'
order by inst_id,group_number;
