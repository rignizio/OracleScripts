select entity_name
      ,metric_column_name
      ,metric_column_label
      ,collection_time
      ,value
from sysman.GC$METRIC_VALUES
where 1=1
and METRIC_COLUMN_NAME = 'avg_sync_singleblk_read_latency'
--and entity_name like 'erprdb_pstdby2%'
--and entity_name like 'BENDB_%'
and entity_name like 'spdb%'
order by entity_name,collection_time