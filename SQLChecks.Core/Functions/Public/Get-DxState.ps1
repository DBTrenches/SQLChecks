function Get-DxState {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([ValidDxTagGenerator])]
        [string]$Tag,

        [Parameter(Mandatory)]
        [DbaInstance]$SqlInstance
    )

    $DxQuery = Get-DxQuery -Tag $Tag

    $DxState = Invoke-DbaQuery -Query $DxQuery -SqlInstance $SqlInstance | 
        Select-Object * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors

    if(0 -eq $DxState.Count){
        Write-Verbose "Empty resultset for [$Tag] query against [$SqlInstance]"
    }

    $DxState
}