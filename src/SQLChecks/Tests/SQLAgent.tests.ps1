Param(
    $Config
)

$serverInstance = $config.ServerInstance

Describe "SQL Agent job schedules" -Tag AgentJobOneActiveSchedule {
    It "No jobs without at least one active schedule on '$($serverInstance)'" {
        (Get-SqlAgentJobsWithNoActiveSchedule -Config $Config | ConvertTo-Json) | Should BeNullOrEmpty
    }
}

Describe "SQL Agent schedules" -Tag AgentJobNoDisabledSchedules {
    It "No jobs with any disabled schedules on '$($serverInstance)'" {
        (Get-SqlAgentJobsWithDisabledSchedule -Config $Config | ConvertTo-Json) | Should BeNullOrEmpty
    }
}

Describe "SQL Agent status" -Tag AgentIsRunning {
    It "SQL Agent is running on '$($serverInstance)'" {
        (Get-SqlAgentService -Config $Config).Status | Should Be "Running"
    }
}

Describe "Unconfigured SQL Agent Alerts" -Tag CheckUnconfiguredSQLAgentAlerts {
    It "All Alerts are enabled and have alert notification on '$($serverInstance)'" {
        (Get-UnconfiguredSQLAgentAlerts -Config $Config | ConvertTo-Json) | Should BeNullOrEmpty
    }
}

Describe "SQL Agent Alerts" -Tag SQLAgentAlerts {
    It "Alerts in config are identical to alerts on '$($serverInstance)'" {
        (Get-SQLAgentAlerts -Config $Config | ConvertTo-Json) | Should BeNullOrEmpty
    }
}

Describe "SQL Agent Operators" -Tag SQLAgentOperators {
    It "Operators in config match enabled operators on '$($serverInstance)'" {
        (Test-SQLAgentOperators -Config $Config | ConvertTo-Json) | Should BeNullOrEmpty
    }
}