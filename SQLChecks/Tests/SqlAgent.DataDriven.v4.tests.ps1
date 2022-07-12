#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}
#Requires -Modules @{ModuleName='Pester';MaximumVersion='4.99';Guid='a699dea5-2c73-4616-a270-1f7abb777e71'}

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

Write-Host "The connection string to be used is '$($DxEntity.ConnectionString)'"
$PSDefaultParameterValues.Add('*:SqlInstance', $DxEntity.ConnectionString)

$ServerAlerts = Get-DxState -Tag SqlAgent.Alerts 
$ConfigAlerts = (Get-DxConfig -Tag SqlAgent.Alerts -EntityName $EntityName | Where-Object Enabled).Name 

Context "SqlAgent on $($DxEntity.ConnectionString)" -Tag SqlAgent {
    
    Describe "SqlAgent.Alerts on $($DxEntity.ConnectionString)" {
        It "Enabled on server: <_>" {
            Compare-Object $ServerAlerts $ConfigAlerts | Should -BeNullOrEmpty
        }
    
        $ServerAlerts | ForEach-Object { 
            It "Enabled on server: $_" {
                $ConfigAlerts | Should -Contain $_
            }
        }
    } 
}

$PSDefaultParameterValues.Remove('*:SqlInstance')
