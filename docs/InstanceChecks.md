# Instance Level Checks

## Global trace flags
```json
"TraceFlags": [3226,7412]
```

Compares global trace flags against a list of trace flags, and reports on the number of discrepancies (trace flags in config but not on the server, or on the server but not in config.)

The example above checks for 3226 (suppress backup messages in the SQL Error log) and 7412 (lightweight query profiling).

## Number of error logs
```json
"NumErrorLogs": 14
```

Compares the configured number of SQL error logs against a configured value.

Assuming you have a job to cycle your error logs daily, a value of 14 would give you 2-weeks worth of logs assuming no additional restarts.

## sp_configure settings
```json
"SpConfig": {
    "MaxDegreeOfParallelism": 0,
    "XpCmdShellEnabled": 0,
    "ShowAdvancedOptions": 0
}
```

Checks the configured value against the value specified in config.  Each value checked is reported as an individual test result.

The example above would check that MaxDop was 1, Show Advanced Options was off, and xp_cmdshell was disabled.

## Startup Extended Event Sessions
```json
"StartupXEvents" : [
    "system_health"
    ,"telemetry_xevents"
]
```

Checks that the extended event sessions configured to run at startup.  If you want to verify there are no sessions set to startup (not recommended!) then provide an empty array.

## Database mail
```json
"DatabaseMail": {}
```

Checks that the database mail SpConfigure option is set, and that a default global profile has been set.