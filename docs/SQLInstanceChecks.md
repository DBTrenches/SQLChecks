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

## Sysadmins
```json
"Sysadmins": ["sa"]
```

Checks that the members of the `sysadmin` server role matches the configuration.

## TempDB Configuration
```json
"TempDBConfiguration": {
        "NumberOfFiles": 8,
        "TotalSizeMB": 12000
    }
```

Checks that the number of tempdb files and total size matches the configuration.

## Resource Governor Setting
```json
"ResourceGovernorSetting": {
        "IsEnabled": 1,
        "ClassifierFunction": "dbo.ResourceGovernorClassifierFunction"
    }
```

Checks resource governor is enabled/disabled. If json configuration is set to `"IsEnabled": 1`, then an additional check will run to ensure the correct classifier function is set.

## Resource Governor Pool / Workload Group Configuration
```json
"ResourceGovernorPools": [
        {
            "ResourcePoolName": "AppPool",
            "WorkloadGroupName": "AppGroup",
            "PoolCapCpuPercent": 20,
            "PoolMinCpuPercent": 0,
            "PoolMaxCpuPercent": 100,
            "PoolMinMemoryPercent": 0,
            "PoolMaxMemoryPercent": 100,
            "GroupRequestMaxMemoryGrantPercent": 25,
            "GroupMaxDop": 1
        },
        {
            "ResourcePoolName": "default",
            "WorkloadGroupName": "default",
            "PoolCapCpuPercent": 100,
            "PoolMinCpuPercent": 0,
            "PoolMaxCpuPercent": 100,
            "PoolMinMemoryPercent": 0,
            "PoolMaxMemoryPercent": 100,
            "GroupRequestMaxMemoryGrantPercent": 25,
            "GroupMaxDop": 1
        },
        {
            "ResourcePoolName": "internal",
            "WorkloadGroupName": "internal",
            "PoolCapCpuPercent": 100,
            "PoolMinCpuPercent": 0,
            "PoolMaxCpuPercent": 100,
            "PoolMinMemoryPercent": 0,
            "PoolMaxMemoryPercent": 100,
            "GroupRequestMaxMemoryGrantPercent": 25,
            "GroupMaxDop": 0
        }
    ]
```

Compares the resource governor pool and workload group settings between source and target and reports any discrepancies (changes in values or number of pool/groups). `New-ResourceGovernorJSONConfig` can be used to output the settings of a server to the correct JSON format shown above.

## Lock Pages in Memory (LPIM)
```json
"LockPagesInMemoryEnabled": 1
```

Checks that the LPIM setting on server matches the configuration

## Instant File Initialization (IFI)
```json
"IFIEnabled": 1
```

Checks that the IFI setting on server matches the configuration

## SQL Server Service startup
```json
"SQLServicesStartup": {}
```

Checks that the SQL Engine and SQL Agent services are set to automatic startup.

## SQL Endpoints
```json
"SQLEndpoints": [
        "Hadr_endpoint",
        "ServiceBrokerEndpoint"
    ]
```

Checks that the list of endpoints in the config are started successfully on the server.

## SQL Managed Backups
```json
"UnconfiguredManagedBackups": {
      "ExcludeDatabases": [ "DB1", "DB2" ]
    },
```

Checks that all databases on the server are configured with SQL managed backups to Azure. Option available to exclude databases from the check.

