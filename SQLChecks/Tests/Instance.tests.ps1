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

Describe "Service.TraceFlags" -Tag Service.TraceFlags {
    BeforeDiscovery {
        $ServerTraceFlagCollection = Get-DxState Service.TraceFlags @Connect 
        $ConfigTraceFlagCollection = $DxEntity.Service.TraceFlags 
        $TraceFlagCollection = $ConfigTraceFlagCollection | ForEach-Object {
            $TraceFlag = $_
            $ServerTraceFlag = $ServerTraceFlagCollection | Where-Object { $_.TraceFlag -eq $TraceFlag }
            @{
                TraceFlag = [int]$TraceFlag
                ExistsInConfig = $true
                ExistsOnServer = [bool]$ServerTraceFlag
            }
        }

        $ServerTraceFlagCollection | Where-Object { $_.TraceFlag -NotIn $ConfigTraceFlagCollection } | ForEach-Object {
            $TraceFlagCollection += @{
                TraceFlag = $_.TraceFlag
                ExistsInConfig = $false
                ExistsOnServer = $true
            }
        }
    }

    It "TraceFlag: <_.TraceFlag> " -ForEach $TraceFlagCollection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
    }
}

Describe "Service.SysConfigurations " -Tag Service.SysConfigurations, SpConfigure {
    BeforeDiscovery {
        $ServerSysConfigurationCollection = Get-DxState Service.SysConfigurations @Connect 
        $ConfigSysConfigurationCollection = $DxEntity.Service.SysConfigurations 
        $SysConfigurationCollection = $ConfigSysConfigurationCollection | ForEach-Object {
            $SysConfiguration = $_.Name
            $ServerSysConfiguration = $ServerSysConfigurationCollection | Where-Object { $_.Name -eq $SysConfiguration }
            @{
                SysConfiguration = $SysConfiguration
                ExistsInConfig = $true
                ExistsOnServer = [bool]$ServerSysConfiguration
                ConfigSetting = $_.Value
                ServerSetting = $ServerSysConfiguration.Value
                ValueInUse = $ServerSysConfiguration.ValueInUse
            }
        }

        # SysConfigurations are static, but we want to assert that the SqlLibrary query
        # is 1:1 aligned with all config values. therefore keep the check for orphans
        $ServerSysConfigurationCollection | Where-Object { $_.Name -NotIn $ConfigSysConfigurationCollection.Name } | ForEach-Object {
            $SysConfigurationCollection += @{
                SysConfiguration = $_.SysConfiguration
                ExistsInConfig = $false
                ExistsOnServer = $true
                ConfigSetting = $null
                ServerSetting = $_.Value
                ValueInUse = $_.ValueInUse
            }
        }
    }

    It "SysConfiguration: '<_.SysConfiguration>' " -ForEach $SysConfigurationCollection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
        $_.ServerSetting | Should -BeExactly $_.ConfigSetting
        $_.ValueInUse | Should -BeExactly $_.ServerSetting
    }
}
