function Get-DxQuery {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([DxTagGenerator])]
        [string]$Tag
    )

    $DxSqlLibrary[$Tag].QueryText
}