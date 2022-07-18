#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

[CmdletBinding()]
Param(
    [string]$EntityName = $DxDefaults.EntityName
)

if ($PSBoundParameters.Keys -contains 'EntityName') {
    Write-Verbose "User-selected entity will be used. "
}
else {
    Write-Verbose "Default entity will be used. "
}

Write-Host "Selected entity is '$EntityName' "

$DxEntity = $DxEntityLibrary.$EntityName

$ConnectionString = $DxEntity.ConnectionString

Write-Host "The connection string to be used is '$ConnectionString'"
$Connect = @{SqlInstance = $ConnectionString}

$ServerAlertCollection = Get-DxState -Tag SqlAgent.Alerts @Connect
$ConfigAlertCollection = $DxEntity.SqlAgent.Alerts | Where-Object Enabled

Describe "SqlAgent.Alerts on $ConnectionString" -Tag SqlAgent.Alerts {   
    $ServerAlertCollection.Name | Where-Object { $_ -NotIn $ConfigAlertCollection.Name } | ForEach-Object { 
        It "Alert on Server not in config: $_" {
            $_ | Should -Be $null
        }
    }

    It "Alert counts should match from server to config" {
        $ConfigAlertCollection.Count | Should -BeExactly $ServerAlertCollection.Count 
    }

    $ConfigAlertCollection | ForEach-Object {
        $AlertName = $_.Name 

        It "Alert exists on server: $AlertName" {
            $AlertName | Should -BeIn $ServerAlertCollection.Name 
        }
    }
} 

$ServerOperatorCollection = Get-DxState -Tag SqlAgent.Operators @Connect
$ConfigOperatorCollection = $DxEntity.SqlAgent.Operators 

Describe "SqlAgent.Operators on $ConnectionString" -Tag SqlAgent.Operators {   
    $ServerOperatorCollection.Name | Where-Object { $_ -NotIn $ConfigOperatorCollection.Name } | ForEach-Object { 
        It "Operator on Server not in config: $_" {
            $_ | Should -Be $null
        }
    }

    It "Operator counts should match from server to config" {
        $ConfigOperatorCollection.Count | Should -BeExactly $ServerOperatorCollection.Count 
    }

    $ConfigOperatorCollection | ForEach-Object {
        $ConfigName = $_.Name
        $ConfigEmail = $_.Email
        $ServerOperator = $ServerOperatorCollection | Where-Object Name -Eq $ConfigName 

        It "'$($ServerOperator.Email)' matches '$ConfigEmail'. " {
            Write-Host "a $($ServerOperator.Email)"
            Write-Host "b $ConfigEmail"
            $ServerOperator.Email | Should Be $ConfigEmail
        }
    }
}
