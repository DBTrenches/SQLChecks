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

Describe "Management.NumErrorLogs" -Tag Management.NumErrorLogs {
    BeforeDiscovery { 
        New-Variable -Name NumErrorLogsCollection -Value @{
            ServerNumErrorLogs = (Get-DxState Management.NumErrorLogs @Connect).NumErrorLogs
            ConfigNumErrorLogs = $DxEntity.Management.NumErrorLogs
        }
    }

    It "NumErrorLogs: <_.ConfigNumErrorLogs> " -ForEach $NumErrorLogsCollection {
        $_.ServerNumErrorLogs | Should -BeExactly $_.ConfigNumErrorLogs
        $_.ServerNumErrorLogs | Should -Not -BeNullOrEmpty
    }
}

Describe "Management.Xevents " -Tag Management.Xevents {
    BeforeDiscovery {
        $ServerStartupXeventCollection = Get-DxState Management.Xevents @Connect | Where-Object { $_.StartupState -eq $true } 
        $ConfigStartupXeventCollection = $DxEntity.Management.Xevents | Where-Object { $_.StartupState -eq $true } 
        $StartupXeventCollection = $ConfigStartupXeventCollection | ForEach-Object {
            $StartupXevent = $_.Name
            $ServerStartupXevent = $ServerStartupXeventCollection | Where-Object { $_.Name -eq $StartupXevent }
            @{
                StartupXevent = $StartupXevent
                ExistsInConfig = $true
                ExistsOnServer = [bool]$ServerStartupXevent
            }
        }

        $ServerStartupXeventCollection | Where-Object { $_.Name -NotIn $ConfigStartupXeventCollection.Name } | ForEach-Object {
            $StartupXeventCollection += @{
                StartupXevent = $_.StartupXevent
                ExistsInConfig = $false
                ExistsOnServer = $true
            }
        }
    }

    It "StartupXevent: <_.StartupXevent> " -ForEach $StartupXeventCollection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
    }
}
