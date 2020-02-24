# SQL Agent Checks

## All jobs have at least one active schedule
```json
"AgentJobOneActiveSchedule": {}
```

Checks that every SQL Agent job has at least one active schedule.  Excludes jobs in the Report Server category.

## There are no disabled schedules linked to agent jobs
```json
"AgentJobNoDisabledSchedules": {}
```

Checks that there is no agent job that has a disabled schedule attached to it.  Excludes jobs in the Report Server category.

## SQL Agent is running
```json
"AgentIsRunning": {}
```

Ensures SQL Agent is running.

## Alerts are enabled and have alert notifications
```json
"CheckUnconfiguredSQLAgentAlerts": {
	 "ExcludeAlert": ["ExcludeAlert1"]
  }
```

Checks all SQL Agent alerts for any alerts that are either disabled or does not have an alert notification enabled.

## Compare alerts in config to alerts on server
```json
"SQLAgentAlerts": [
        "Error Number 823 - OS returned an Error",
        "Severity Level 22: SQL Server Fatal Error Table Integrity Suspect",
        "Severity Level 23: SQL Server Fatal Error: Database Integrity Suspect"
    ]
```

Performs a full comparison of alerts between config and target server and reports on any discrepencies (alerts in config but not on the server, or on the server but not in config). This test is only compares alerts that are enabled and have an alert notification on the target.

## SQL Agent Operators
```json
"SQLAgentOperators": [
        {
            "OperatorName": "AppTeam1",
            "OperatorEmail": "appteam1@mycompany.com"
        },
        {
            "OperatorName": "DBA",
            "OperatorEmail": "DBA@mycompany.com"
        }
    ]
```

Performs a full comparison of operators between config and target server and reports on any discrepencies (operators in config but not on the server, or on the server but not in config). This test only compares operators that are enabled on the target. `New-SQLAgentOperatorsJSONConfig` can be used to output the operators on a server to the correct JSON format shown above.