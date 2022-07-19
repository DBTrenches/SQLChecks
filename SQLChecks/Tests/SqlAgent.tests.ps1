#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

[CmdletBinding()]
Param(
    [string]$EntityName = $DxDefaults.EntityName
)

BeforeAll {
    if ($PSBoundParameters.Keys -contains 'EntityName') {
        Write-Verbose "User-selected entity will be used. "
    }
    else {
        Write-Verbose "Default entity will be used. "
    }

    Write-Host "Selected entity is '$EntityName' "
    Write-Host "The connection string to be used is '$($DxEntityLibrary.$EntityName.ConnectionString)' "
}

BeforeDiscovery {
    $DxEntity = $DxEntityLibrary.$EntityName

    $ConnectionString = $DxEntity.ConnectionString

    New-Variable -Name Connect -Value @{SqlInstance = $ConnectionString}
}

Describe "SqlAgent.Alerts on '$ConnectionString' " -Tag SqlAgent.Alerts {
    BeforeDiscovery {
        $ServerAlertCollection = Get-DxState -Tag SqlAgent.Alerts @Connect 
        $ConfigAlertCollection = $DxEntity.SqlAgent.Alerts 
        $AlertCollection = $ConfigAlertCollection | Where-Object Enabled | ForEach-Object {
            $AlertName = $_.Name
            $ServerAlert = $ServerAlertCollection | Where-Object {$_.Name -eq $AlertName}
            $ExistsOnServer = [bool]$ServerAlert
            @{
                AlertName = $AlertName
                ExistsInConfig = $true
                ExistsOnServer = $ExistsOnServer
            }
        }
        
        $ServerAlertCollection | Where-Object { $_.Name -NotIn $ConfigAlertCollection.Name } | ForEach-Object {
            $AlertCollection += @{
                AlertName = $_.Name
                ExistsInConfig = $false
                ExistsOnServer = $true
            }
        }
    }
    
    It "Alert: '<_.AlertName>' " -ForEach $AlertCollection {
        $_.ExistsOnServer | Should -BeTrue
        $_.ExistsInConfig | Should -BeTrue
    }
}

Describe "SqlAgent.Operators on '$ConnectionString' " -Tag SqlAgent.Operators {
    BeforeDiscovery {
        $OperatorData = @{
            ServerData = Get-DxState -Tag SqlAgent.Operators @Connect 
            ConfigData = $DxEntity.SqlAgent.Operators 
        }
        New-Variable -Name OperatorCollection -Value (Join-DxConfigAndState @OperatorData)
    }
    
    # below `It` title displays aligned email address on success
    # "Operator: '<_.OperatorName>' `n      Email:    '<_.Config.Email>'"
    It "Operator: '<_.Name>' " -ForEach $OperatorCollection {
        $_.ExistsOnServer | Should -BeTrue
        $_.ExistsInConfig | Should -BeTrue
        $_.Server.Email | Should -BeExactly $_.Config.Email
    }
}

Describe "SqlAgent.Status on '$ConnectionString' " -Tag SqlAgent.Status {
    BeforeDiscovery {
        New-Variable -Name SqlAgentStatus -Value (Get-DxState SqlAgent.Status @Connect)
    }
    
    It "Agent is running and auto-restart. " -ForEach $SqlAgentStatus {
        $_.StatusDescription | Should -BeExactly "Running"
        $_.StartupTypeDescription | Should -BeExactly "Automatic"
    }
}

Describe "SqlAgent.JobSchedules on '$ConnectionString' " -Tag SqlAgent.JobSchedules {
    BeforeDiscovery {
        New-Variable -Name JobsWithDisabledSchedules -Value (Get-DxState SqlAgent.JobSchedules.Disabled @Connect)
        New-Variable -Name JobsWithNoActiveSchedules -Value (Get-DxState SqlAgent.JobSchedules.NoneActive @Connect)
    }
    
    It "No jobs have a disabled schedule. " {
        $JobsWithDisabledSchedules.Count | Should -Be 0
        $JobsWithDisabledSchedules.Count | Should -Not -BeNullOrEmpty
    }

    It "All jobs have at least one active schedule. " {
        $JobsWithNoActiveSchedules.Count | Should -Be 0
        $JobsWithNoActiveSchedules.Count | Should -Not -BeNullOrEmpty
    }

    It "Job: '<_.JobName>' . " -ForEach $JobsWithDisabledSchedules -Tag SqlAgent.JobSchedules.Disabled {
        # this should always fail. test will only execute if a job with a disabled
        # schedule is found during Discovery
        "Schedule: '$($_.DisabledScheduleName)' is disabled. " | Should -Be "All schedules are active. "
    }
    It "Job: '<_.JobName>' . " -ForEach $JobsWithNoActiveSchedules -Tag SqlAgent.JobSchedules.NoneActive {
        # this should always fail. test will only execute if a job without an 
        # active schedule is found during Discovery
        "Has no active schedule. " | Should -Be "Has an active schedule. "
    }
}
