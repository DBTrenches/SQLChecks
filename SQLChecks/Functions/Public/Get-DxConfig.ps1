
function Get-DxConfig {
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
