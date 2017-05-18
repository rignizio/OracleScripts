set linesize 1000 pagesize 0
select * from table(dbms_xplan.display_awr('&SQL_ID',null,null,'typical +peeked_binds')); 
