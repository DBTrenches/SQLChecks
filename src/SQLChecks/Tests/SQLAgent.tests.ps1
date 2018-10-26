Param(
    $Config
)

$serverInstance = $config.ServerInstance

Describe "SQL Agent job schedules" -Tag AgentJobOneActiveSchedule {
    It "No jobs without at least one active schedule on $serverInstance" {
        @(Get-SqlAgentJobsWithNoActiveSchedule -Config $Config).Count | Should Be 0
    }
}

Describe "SQL Agent schedules" -Tag AgentJobNoDisabledSchedules {
    It "No jobs with any disabled schedules on $serverInstance" {
        @(Get-SqlAgentJobsWithDisabledSchedule -Config $Config).Count | Should Be 0
    }
}

Describe "SQL Agent status" -Tag AgentIsRunning {
    It "SQL Agent is running on $serverInstance" {
        (Get-SqlAgentService -Config $Config).Status | Should Be "Running"
    }
}