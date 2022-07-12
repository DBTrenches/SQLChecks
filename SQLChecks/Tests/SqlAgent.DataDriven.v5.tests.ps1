#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}
#Requires -Modules @{ModuleName = 'Pester';ModuleVersion = '5.0';Guid = 'a699dea5-2c73-4616-a270-1f7abb777e71'}

[CmdletBinding()]
Param(
    [string]$EntityName = $DxDefaults.EntityName
)

BeforeDiscovery {
    if($PSBoundParameters.Keys -contains 'EntityName'){
        Write-Host "User-supplied config will be used. Selected Entity is '$EntityName'. "
    }
    else {
        Write-Host "Default config will be used. Selected Entity is '$($DxDefaults.EntityName)'"
    }
    # $PSDefaultParameterValues.Add('*:EntityName',$EntityName) # doesn't apply at Discovery time when it's needed

    $DxEntity = $DxEntityLibrary.$EntityName

    Write-Host "The connection string to be used is '$($DxEntity.ConnectionString)'"
    $PSDefaultParameterValues.Add('*:SqlInstance',$DxEntity.ConnectionString)
}

Context "SqlAgent on $($DxEntity.ConnectionString)" -Tag SqlAgent {
    BeforeAll {
        $ServerEnabledAlerts = Get-DxState -Tag SqlAgent.Alerts 
        $ServerEnabledAlerts | Out-Null
    }

    Describe "SqlAgent.Alerts on $($DxEntity.ConnectionString)" -Tag SqlAgent.Alerts {
        It "Enabled on server: <_>" -ForEach (
            # Get-DxConfig -Tag SqlAgent.Alerts -EntityName $EntityName | Where-Object Enabled
            $DxEntity.SqlAgent.Alerts | Where-Object Enabled # no tests detected
        ).Name {
            $ServerEnabledAlerts | Should -Contain $_
        }

        It "No unknown alerts on server. " -ForEach (
            (($DxEntity.SqlAgent.Alerts | Where-Object Enabled).Name | Sort-Object) -join [System.Environment]::NewLine
        ) {
            ($ServerEnabledAlerts | Sort-Object) -join [System.Environment]::NewLine | Should -Be $_
        }
    } 
}

AfterAll {
    # $PSDefaultParameterValues.Remove('*:EntityName')
    $PSDefaultParameterValues.Remove('*:SqlInstance')
}