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

    Write-Host "The connection string to be used is '$ConnectionString' "
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
