#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

[CmdletBinding()]
Param(
    [string]$EntityName = $DxDefaults.EntityName
)

BeforeDiscovery {    
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
}

Describe "SqlAgent.Alerts on '$ConnectionString" -Tag SqlAgent.Alerts {
    BeforeDiscovery {
        $ServerAlertCollection = Get-DxState -Tag SqlAgent.Alerts @Connect 
        $ConfigAlertCollection = $DxEntity.SqlAgent.Alerts 
        $AlertCollection = $ConfigAlertCollection | 
            Where-Object Enabled | 
            ForEach-Object {
                $AlertName = $_.Name
                $ServerAlert = $ServerAlertCollection | Where-Object {$_.Name -eq $AlertName}
                $ExistsOnServer = [bool]$ServerAlert
                @{
                    AlertName = $AlertName
                    ExistsInConfig = $true
                    ExistsOnServer = $ExistsOnServer
                }
            }
        
        $ServerAlertCollection | Where-Object { $_.Name -NotIn $ConfigAlertCollection.Name } | ForEach-Object {
            $AlertCollection += @{
                AlertName = $_.Name
                ExistsInConfig = $false
                ExistsOnServer = $true
            }
        }
    }
    
    It "'<_.AlertName>' exists on server and config" -ForEach $AlertCollection {
        $_.ExistsOnServer | Should -BeTrue
        $_.ExistsInConfig | Should -BeTrue
    }
}