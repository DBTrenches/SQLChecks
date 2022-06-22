#Requires -Modules @{ModuleName='SQLChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

[CmdletBinding()]
Param(
    $DxEntity
)

BeforeAll {
    $SqlInstance = if($PSBoundParameters.Keys -contains 'DxEntity'){
        $DxEntity.ConnectionString
        Write-Host "Using user-supplied config value"
    }
    else {
        $DxDefaults.ConnectionString
        Write-Host "Using module default connection string"
    }

    $PSDefaultParameterValues.Add('*:SqlInstance',$SqlInstance)

}

Describe "SQL Agent Alerts on [$SqlInstance]" -Tag SqlAgent.Alerts {

    BeforeAll {
        $ServerEnabledAlerts = (Get-DxState -Tag SqlAgent.Alerts).AlertName
        Write-Host "Examining Enabled Alerts on $SqlInstance"
        $ServerEnabledAlerts | Out-Null # quiesce false postive for linter PSScriptAnalyzer(PSUseDeclaredVarsMoreThanAssignments)
    }

    # uncomment for hunt-and-peck debugging. Variables defined in runtime not available to text titles assigned in discovery
    # It "Value of `$SqlInstance variable is 'data-1'." {$SqlInstance | Should -Be 'data-1'}

    Context "Enabled SqlAgent Alerts" -ForEach $DxEntityConfig.SqlAgent.Alerts.EnabledAlerts {
        It "'<_>'" {
            $ServerEnabledAlerts | Should -Contain $_
        }
    }
}

AfterAll {
    $PSDefaultParameterValues.Remove('*:SqlInstance')
}
