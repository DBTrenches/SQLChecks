Function Initialize-DxCheck {
<#
.SYNOPSIS
    Exports `OUTER JOIN` of Server and Config data for `-Tag` to the Parent Scope as `$Collection`

.DESCRIPTION
    One-liner to handle prepared Check material based on an input `-Tag`. Exports the `$Collection`
    variable to the global: scope. Ostensibly should be ablt to export to the parent (1) scope per
    the docs but was not able to achieve this on cursory testing. Still needs the Database[] array
    pre-populated for multi-DB queries at this time.

.LINK
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes#managing-scope
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet([DxTagGenerator])]
        [string]
        $Tag,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $EntityName = $DxDefaults.EntityName,

        [Parameter()]
        [string[]]
        $Database,

        [Parameter()]
        [string]
        $KeyName = 'Name'
    )

    $DxEntity = $DxEntityLibrary.$EntityName

    $ConnectionString = $DxEntity.ConnectionString

    $Join = @{
        ServerData = Get-DxState -Tag $Tag -SqlInstance $ConnectionString -Database $Database
        ConfigData = $DxEntity.SqlAgent.Alerts
        KeyName    = $KeyName
    }

    $Var = @{
        Name  = 'Collection'
        Value = Join-DxConfigAndState @Join
        Scope = 'Global'
        Force = $true
    }
    
    New-Variable @Var
}
