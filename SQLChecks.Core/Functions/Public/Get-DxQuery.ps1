function Get-DxQuery {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([ValidDxTagGenerator])]
        [string]$Tag
    )

    $DxQueryCollection[$Tag].QueryText
}