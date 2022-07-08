
function Get-DxConfig {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([DxTagGenerator])]
        # [Alias('Tags')]
        # [string[]]$Tag, # TODO: string[]
        [string]$Tag

        # $DxEntity
    )

    Invoke-Expression "`$DxEntityConfig.$Tag"
}
