
function Get-DxConfig {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([ValidDxTagGenerator])]
        # [Alias('Tags')]
        # [string[]]$Tag, # TODO: string[]
        [string]$Tag

        # $DxEntity
    )

    Invoke-Expression "`$DxEntityConfig.$Tag"
}
