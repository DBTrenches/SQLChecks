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

Describe "Service.TraceFlags " -Tag Service.TraceFlags {
    BeforeDiscovery {
        Initialize-DxCheck Service.TraceFlags -KeyName TraceFlag -EntityName $EntityName
    }

    It "TraceFlag test is running" -ForEach $Collection[0] {
        ($_.ExistsInConfig).Count | Should -BeExactly 1 -Because "In order to confirm the test ran, an empty object is returned from `Join-DxConfigAndState` when there is a null set on both server and config "
    }
    Context "TraceFlag: <_.Name> " -ForEach $Collection {
        It "Is in config " {
            $_.ExistsInConfig | Should -BeTrue -Because "We should have all Trace Flags documented in Config. "
        }
        It "Is deployed " {
            $_.ExistsOnServer | Should -BeTrue -Because "All config Trace Flags should be applied. "
        }
    }
}

Describe "Service.SysConfigurations " -Tag Service.SysConfigurations, SpConfigure {
    BeforeDiscovery {
        Initialize-DxCheck Service.SysConfigurations -EntityName $EntityName
    }

    It "SysConfiguration: '<_.Name>' " -ForEach $Collection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
        $_.Server.Value | Should -BeExactly $_.Config.Value
        $_.Server.ValueInUse | Should -BeExactly $_.Server.Value
    }
}

Describe "Service.TempDbConfiguration " -Tag Service.TempDbConfiguration {
    BeforeDiscovery {
        Initialize-DxCheck Service.TempDbConfiguration -KeyName DbName -EntityName $EntityName
    }

    It "NumberOfFiles: '<_.Config.NumberOfFiles>' " -ForEach $Collection {
        $_.ExistsInConfig | Should -BeTrue
        $_.Server.NumberOfFiles | Should -BeExactly $_.Config.NumberOfFiles
    }
    
    It "TotalSizeMb: '<_.Config.TotalSizeMB>' " -ForEach $Collection {
        $_.ExistsInConfig | Should -BeTrue
        $_.Server.TotalSizeMB | Should -BeExactly $_.Config.TotalSizeMB
    }
}

Describe "Service.InstantFileInitializationSetting on '$ConnectionString' " -Tag Service.InstantFileInitializationSetting {
    BeforeDiscovery {
        Initialize-DxCheck Service.InstantFileInitializationSetting -EntityName $EntityName
    }
    It "InstantFileInitializationSetting: '<_.Name>' " -ForEach $Collection {
        $_.ExistsOnServer | Should -BeTrue
        $_.ExistsInConfig | Should -BeTrue
        $_.Server.IFIEnabled | Should -Be $_.Config.IFIEnabled
    }
}

Describe "Service.CommittedMemory " -Tag Service.CommittedMemory {

    BeforeAll {

        # this dot-source can be removed if there is a script-level `BeforeAll{}` copy

        . $PSScriptRoot/Set-DxPesterVariables.ps1

        $ServerValue = (Get-DxState Service.CommittedMemory @Connect).NumErrorLogs

    }

    It "CommittedMemory: $($DxEntityLibrary.$EntityName.Service.CommittedMemory) " {

        $ServerValue.committed_kb | Should -Belessorequal $ServerValue.committed_target_kb -1000



    }

}