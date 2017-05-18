set pagesize 20
select * from (
	select inst_id 
      , sql_id
      , count(*) DBTime
      , round(count(*)*100/sum(count(*)) over (partition by inst_id), 2) pctload
from gv$active_session_history
where sample_time > sysdate - 1/1440
and session_type <> 'BACKGROUND'
and sql_id is not null
group by inst_id,sql_id
order by count(*) desc
)
where ROWNUM <=25


