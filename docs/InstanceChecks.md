# Instance Level Checks

In all cases if the config value is not present the test will be skipped.

## Global trace flags
Compares global trace flags against a list of trace flags, and reports on the number of discrepancies (trace flags in config but not on the server, or on the server but not in config.)

The example below checks for 3226 (suppress backup messages in the SQL Error log) and 7412 (lightweight query profiling).

```json
"TraceFlags": [3226,7412]
```

## Number of error logs
Compares the configured number of SQL error logs against a configured value.

Assuming you have a job to cycle your error logs daily, a value of 14 would give you 2-weeks worth of logs assuming no additional restarts.

```json
"NumErrorLogs": 14
``` 

## sp_configure settings
Checks the runtime value against the value specified in config.  Each value checked is reported as an individual test result.

The example below would check that MaxDop was 1, Show Advanced Options was off, and xp_cmdshell was disabled.

```json
"SpConfig": {
    "MaxDegreeOfParallelism": 0,
    "XpCmdShellEnabled": 0,
    "ShowAdvancedOptions": 0
}
```