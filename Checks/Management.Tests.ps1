#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

# PsScriptAnalyzer reports false positive for $vars defined in `Discovery` not used until `It`
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

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
    . $PSScriptRoot/../Scripts/Set-DxPesterVariables.ps1
}

BeforeAll {
    . $PSScriptRoot/../Scripts/Set-DxPesterVariables.ps1
}

Describe "Management.NumErrorLogs" -Tag Management.NumErrorLogs { 
    BeforeAll {
        # @Connect splat is not available to this scope
        $ServerValue = (Get-DxState Management.NumErrorLogs @Connect).NumErrorLogs
        $ConfigValue = $DxEntityLibrary.$EntityName.Management.NumErrorLogs
    }

    It "NumErrorLogs: $($DxEntityLibrary.$EntityName.Management.NumErrorLogs) " {
        $ServerValue | Should -BeExactly $ConfigValue
        $ConfigValue | Should -Not -BeNullOrEmpty
    }
}

Describe "Management.Xevents " -Tag Management.Xevents {
    BeforeDiscovery {
        $StartupXeventData = @{
            ServerData = Get-DxState Management.Xevents @Connect | Where-Object { $_.StartupState -eq $true } 
            ConfigData = $DxEntity.Management.Xevents | Where-Object { $_.StartupState -eq $true } 
        }
        $StartupXeventCollection = Join-DxConfigAndState @StartupXeventData
    }

    It "StartupXevent: <_.Name> " -ForEach $StartupXeventCollection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
    }
}

Describe "Management.DbMail.DefaultProfile " -Tag Management.DbMail.DefaultProfile {
    BeforeAll {
        $ServerState = Get-DxState Management.DbMail.DefaultProfile @Connect
    }
    It "DbMail.DefaultProfile " {
        $ServerState.IsDefault | Should -BeTrue
    }
}

Describe "Management.ResourceGovernor.ResourceGovernorState " -Tag Management.ResourceGovernor.ResourceGovernorState {
    BeforeDiscovery {
        Initialize-DxCheck Management.ResourceGovernor.ResourceGovernorState -KeyName ClassifierFunction
    }
    Context "ResourceGovernor.ResourceGovernorState " -ForEach $Collection {
        It "'<_.Name>' classifier exists on the server " {
            $_.ExistsOnServer | Should -BeTrue
        }
        It "'<_.Name>' classifier exists in config " {
            $_.ExistsInConfig | Should -BeTrue
        }
        It "Resource governor has the correct server value for 'IsEnabled' (<_.Config.IsEnabled>) " {
            $_.Server.IsEnabled | Should -BeExactly $_.Config.IsEnabled
        }
        It "Resource governor has the correct server value for 'IsReconfigurationPending' (<_.Config.IsReconfigurationPending>) " {
            $_.Server.IsReconfigurationPending | Should -BeExactly $_.Config.IsReconfigurationPending
        }
    }
}

Describe "Management.ResourceGovernor.Pools " -Tag Management.ResourceGovernor.Pools {
    BeforeDiscovery {
        Initialize-DxCheck Management.ResourceGovernor.Pools -KeyName resourcepoolname
    }
    Context "ResourceGovernor.Pools: '<_.Name>' " -ForEach $Collection {
        It "Exists on the server " {
            $_.ExistsOnServer | Should -BeTrue -Because "ResourceGovernor.Pools values should be remove from config when obsolete. "
        }
        It "Exists in config " {
            $_.ExistsInConfig | Should -BeTrue -Because "ResourceGovernor.Pools entries that exist on the server should be registered in config. " 
        }

        It "Has the correct value for 'PoolCapCpuPercent' (<_.Config.PoolCapCpuPercent>) " {
            $_.Server.PoolCapCpuPercent | Should -BeExactly $_.Config.PoolCapCpuPercent
        }
        It "Has the correct value for 'PoolMinCpuPercent' (<_.Config.PoolMinCpuPercent>) " {
            $_.Server.PoolMinCpuPercent | Should -BeExactly $_.Config.PoolMinCpuPercent
        }
        It "Has the correct value for 'PoolMaxCpuPercent' (<_.Config.PoolMaxCpuPercent>) " {
            $_.Server.PoolMaxCpuPercent | Should -BeExactly $_.Config.PoolMaxCpuPercent
        }
        It "Has the correct value for 'PoolMinMemoryPercent' (<_.Config.PoolMinMemoryPercent>) " {
            $_.Server.PoolMinMemoryPercent | Should -BeExactly $_.Config.PoolMinMemoryPercent
        }
        It "Has the correct value for 'PoolMaxMemoryPercent' (<_.Config.PoolMaxMemoryPercent>) " {
            $_.Server.PoolMaxMemoryPercent | Should -BeExactly $_.Config.PoolMaxMemoryPercent
        }
        It "Has the correct value for 'GroupRequestMaxMemoryGrantPercent' (<_.Config.GroupRequestMaxMemoryGrantPercent>) " {
            $_.Server.GroupRequestMaxMemoryGrantPercent | Should -BeExactly $_.Config.GroupRequestMaxMemoryGrantPercent
        }
        It "Has the correct value for 'GroupMaxDop' (<_.Config.GroupMaxDop>) " {
            $_.Server.GroupMaxDop | Should -BeExactly $_.Config.GroupMaxDop
        }
    }
}
