function Get-DxState {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([ValidDxTagGenerator])]
        [string]$Tag,

        [DbaInstance]$SqlInstance
    )

    $DxQuery = Get-DxQuery -Tag $Tag

    $DxState = Invoke-DbaQuery -Query $DxQuery -SqlInstance $SqlInstance

    if(0 -eq $DxState.Count){
        Write-Verbose "Empty resultset for [$Tag] query against [$SqlInstance]"
    }

    $DxState
}