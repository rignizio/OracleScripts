select snap_id
      ,instance_number
	  ,sql_id,name
	  ,position
	  ,datatype_string
	  ,was_captured
	  ,last_captured
	  ,value_string
from DBA_HIST_SQLBIND 
where sql_id='&SQLL_ID'
order by last_captured desc nulls last,snap_id,position;
