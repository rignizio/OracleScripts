-- Get DBID
select dbid from v$database;

 -- Get SNAP_ID's
select instance_number,snap_id,begin_interval_time,end_interval_time,startup_time
from dba_hist_snapshot order  by snap_id desc;

-- RUn for Instance HTML
set veri off;
set feedback off;
set linesize 8000 pagesize 0
set termout on
SELECT OUTPUT
FROM TABLE (dbms_workload_repository.AWR_REPORT_HTML(
 l_dbid=>2567083523,
 l_inst_num=>1,
 l_bid=>36885,
 l_eid=>36903,
 l_options=>8
 )
);

-- Run for global HTML
set veri off;
set feedback off;
set linesize 8000 pagesize 0
set termout on
SELECT OUTPUT
FROM TABLE (dbms_workload_repository.AWR_GLOBAL_REPORT_HTML (
 l_dbid=>2567083523,
 l_inst_num=>'1,2',
 l_bid=>36885,
 l_eid=>36903,
 l_options=>8
 )
);
