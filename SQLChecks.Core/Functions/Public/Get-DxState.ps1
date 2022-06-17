function Get-DxState {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([ValidDxTagGenerator])]
        [string]$Tag,

        [DbaInstance]$SqlInstance
    )

    $DxQuery = Get-DxQuery -Tag $Tag

    Invoke-DbaQuery -Query $DxQuery -SqlInstance $SqlInstance
}