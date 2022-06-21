#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0';Guid='a699dea5-2c73-4616-a270-1f7abb777e71'}

[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    $DxEntity
)

BeforeAll {
    $SqlInstance = $DxEntity.ConnectionString
}

Describe "SQL Agent Alerts on [$SqlInstance]" -Tag SqlAgent.Alerts {
    BeforeAll {
        $SqlInstance = $DxEntity.ConnectionString
        $PSDefaultParameterValues.Add('Get-DxState:SqlInstance',$SqlInstance)
    }

    Context "Enabled SqlAgent alert <_> on [$SqlInstance]" -ForEach $DxEntityConfig.SqlAgent.Alerts.EnabledAlerts {
        It "bar" {
            $SqlInstance | Should -Be 'data-1'
        }
        It "Alerts in config are identical to alerts on $SqlInstance" {
            (Get-DxState -Tag SqlAgent.Alerts).AlertName | Should -Contain $_
            # (Get-DxState -Tag SqlAgent.Alerts -SqlInstance $SqlInstance).AlertName | Should -Contain "Error Number 823 - OS returned an Error"
            # "Error Number 823 - OS returned an Error" | Should -BeIn $AlertName
        }
    }
}

AfterAll {
    $PSDefaultParameterValues.Remove('Get-DxState:SqlInstance')
}
