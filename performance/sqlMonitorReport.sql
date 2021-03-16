SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SELECT DBMS_SQLTUNE.report_sql_monitor(
  sql_id       => '&SQL_ID',
  sql_exec_id  => @SQL_EXEC_ID,
  type         => 'TEXT',
  report_level => 'ALL') AS report
FROM dual;