select inst_id
      ,sql_id
      ,plan_hash_value
      ,operation ||' '||options
      ,object_owner||'.'||object_name
      ,access_predicates
      ,filter_predicates
from gv$sql_plan 
where object_name='&OBJECT_NAME' 
order by sql_id