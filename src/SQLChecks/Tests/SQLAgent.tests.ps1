Param(
    $Config
)

$serverInstance = $config.ServerInstance

Describe "SQL Agent job schedules" -Tag AgentJobOneActiveSchedule {
    Context "Testing agent jobs schedules on $serverInstance" {
        It "No jobs without at least one active schedule on $serverInstance" {
            @(Get-SqlAgentJobsWithNoActiveSchedule -ServerInstance $serverInstance).Count | Should Be 0
        }
    }
}

Describe "SQL Agent schedules" -Tag AgentJobNoDisabledSchedules {
    Context "Testing agent jobs for disabled schedules on $serverInstance" {
        It "No jobs with any disabled schedules on $serverInstance" {
            @(Get-SqlAgentJobsWithDisabledSchedule -ServerInstance $serverInstance).Count | Should Be 0
        }
    }
}