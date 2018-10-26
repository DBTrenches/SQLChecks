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