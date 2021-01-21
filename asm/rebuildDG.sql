-- for Exadata or any ASM
-- Get DISK names

select a.NAME,b.NAME 
from  V$ASM_DISKGROUP a,  V$ASM_DISK b 
where a.GROUP_NUMBER=b.GROUP_NUMBER 
order by  a.name ;


-- STOP DG running on other instances
-- srvctl stop diskgroup -g DATA -n <node>
-- srvctl stop diskgroup -g DATA -n <node>

-- Drop DG
DROP DISKGROUP DATA INCLUDING CONTENTS;

-- Re-create DG
create diskgroup DATA normal redundancy
 disk 'o/*/DATA_CD*' attribute 'au_size' = '4194304'
 , 'sector_size' = '512'
 , 'compatible.asm' = '19.0.0.0.0'
 , 'compatible.rdbms' = '12.1.0.2.0'
 , 'cell.smart_scan_capable' = 'TRUE'; 

-- verify in asmcmd DG is created
-- asmcmd lsdg

-- START DG on other instances
-- srvctl start diskgroup -g DATA -n <node>
-- srvctl start diskgroup -g DATA -n <node>