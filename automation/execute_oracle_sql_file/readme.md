## Execution Options:
* Run against SID
* Run against All Databases
* When using the -all option, the sql script will execute on all of the running oracle instances.
* Run as sysdba


## BladeLogic will download a .sql file from DBA bitbucket repository, and then execute the script using the following syntax:

```sql
    sqlplus / as sysdba @file_from_bitbucket.sql
    OR
    sqlplus / @file_from_bitbucket.sql
```

BladeLogic captures all of the STDOUT and STDERR from the shell session. This captured information in BladeLogic is what will be returned to the requesting process.

The current design doesn't support capture or handling of spooled output. WARNING: If output is spooled to a file, that file will remain on the file system and won't be cleaned up after execution.

The process will not evaluate the contents of the output. It will however evaluate for non-zero exit codes; therefore, SQL scripts should be designed to raise and exception if the resulting data is undesired.

## SQL script requirements for properly capturing output:
1) The SQL script must have:
	 SET feedback ON serveroutput ON;
2) Success & failure criteria must be defined within the script itself. The SQL script will raise an exception if data was not returned as excepted.
     * Example:
    * https://code.paychex.com/projects/DSM/repos/oraclesupport/browse/DisasterRecovery/testing_only/force%20error.sql

* Location in Bitbucket where the scripts are stored should be set to READ ONLY for everyone except for DBA.
* https://code.paychex.com/projects/DSM/repos/oraclesupport/browse/DisasterRecovery/



## Future Enhancements To Investigate:
* Provide functionality to execute in parallel against databases when the -all option is passed
     Currently the execution of a sql script in parallel on a server is not possible since there will be a collision of output with STDOUT.
     The output would be done randomly and could output at the same time on the same line making it difficult to read.
     It's possible to get around this by leveraging oracle's ability to spool out to files; however, that raises 
     an number of challenges (e.g., file naming convention for parsing, permissions of spool file, clean up of file once content has been retrieved, merging spool logs, ensuring there is enough space on disk to spool out to, etc.).

