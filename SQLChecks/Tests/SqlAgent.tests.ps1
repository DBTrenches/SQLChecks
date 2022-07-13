#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

[CmdletBinding()]
Param(
    [string]$EntityName = $DxDefaults.EntityName
)

if ($PSBoundParameters.Keys -contains 'EntityName') {
    Write-Host "User-supplied config will be used. Selected Entity is '$EntityName'. "
}
else {
    Write-Host "Default config will be used. Selected Entity is '$($DxDefaults.EntityName)'"
}

$DxEntity = $DxEntityLibrary.$EntityName

$ConnectionString = $DxEntity.ConnectionString

Write-Host "The connection string to be used is '$ConnectionString'"
$PSDefaultParameterValues.Add('*:SqlInstance', $ConnectionString)

$ServerAlerts = Get-DxState -Tag SqlAgent.Alerts 
$ConfigAlerts = $DxEntity.SqlAgent.Alerts | Where-Object Enabled

Describe "SqlAgent.Alerts on $ConnectionString" -Tag SqlAgent.Alerts {   
    $ServerAlerts | Where-Object { $_ -NotIn $ConfigAlerts.Name } | ForEach-Object { 
        It "Alert on Server not in config: $_" {
            $_ | Should -Be $null
        }
    }
    $ConfigAlerts | ForEach-Object {
        $AlertName = $_.Name 

        It "Alert exists on server: $AlertName" {
            $AlertName | Should -BeIn $ServerAlerts
        }
    }
} 

$ServerOperators = Get-DxState -Tag SqlAgent.Operators 
$ConfigOperators = $DxEntity.SqlAgent.Operators 

Describe "SqlAgent.Operators on $ConnectionString" -Tag SqlAgent.Operators {   
    $ServerOperators.Name | Where-Object { $_ -NotIn $ConfigOperators.Name } | ForEach-Object { 
        It "Operator on Server not in config: $_" {
            $_ | Should -Be $null
        }
    }

    $ConfigOperators | ForEach-Object {
        $ConfigName = $_.Name
        $ConfigEmail = $_.Email
        $ServerOperator = $ServerOperators | Where-Object Name -Eq $ConfigName 

        It "Operator '$ConfigName' exists on server and has correct email: '$ConfigEmail'. " {
            $ServerOperator.Email | Should -BeExactly $ConfigEmail
        }
    }
} 

$PSDefaultParameterValues.Remove('*:SqlInstance')
