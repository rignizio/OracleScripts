-- FLush an individual SQL from an instance
-- Will prompt for SQL_ID of query

declare
    vAddress    v$sqlarea.address%TYPE;
    vHashValue  v$sqlarea.hash_value%type;
begin
SELECT address,hash_value into vAddress,vHashValue
from v$sqlarea where sql_id = '&SQL_ID';
sys.dbms_shared_pool.purge(vAddress||','||vHashValue,'C');  
end;
/
