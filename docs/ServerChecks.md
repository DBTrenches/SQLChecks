# Server Level Checks

## Check Services are running
```json
"RunningServices" : [
      "MSSQLServerOLAPService"
      ,"PowerBIReport*"
      ,"SQLServerReportingServices"
    ]
```

Checks to see if each service is in a "Running" state on the target machine. Service names can use wildcards if needed.