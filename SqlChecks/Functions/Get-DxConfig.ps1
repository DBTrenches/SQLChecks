function Get-DxConfig {
<#
.SYNOPSIS
    Given a $Tag and an $EntityName, return the config value for that Entity at the $Tag path

.DESCRIPTION
    Tags are dot-delimited strings but correspond to valid JSON paths within the resolved
    config files for each Entity. The $DxEntityLibrary module variable is a dictionary
    with entries for each resolved Entity. Invoke-Expression is used to traverse the 
    config PSObject and return the Config value at the $Tag path
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([DxTagGenerator])]
        # [Alias('Tags')]
        # [string[]]$Tag, # TODO: string[]
        [string]$Tag,

        [Parameter(Mandatory)]
        [string]$EntityName

        # $DxEntity
    )

    Invoke-Expression "`$DxEntityLibrary.'$EntityName'.$Tag"
}
