function Get-DxState {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([DxTagGenerator])]
        [string]$Tag,

        [Parameter(Mandatory)]
        [DbaInstance]$SqlInstance,

        [Switch]$NoExpand
    )

    $DxQuery = Get-DxQuery -Tag $Tag

    $DxState = Invoke-DbaQuery -Query $DxQuery -SqlInstance $SqlInstance | 
        Select-Object * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors

    if(0 -eq $DxState.Count){
        Write-Verbose "Empty resultset for [$Tag] query against [$SqlInstance]"
    }

    $ExpandProperty = ($DxState | Get-Member | Where-Object MemberType -EQ 'NoteProperty').Name
    $PropCount = $ExpandProperty.Count

    # If there's only one property in the resultset, expand it to an array
    if($PropCount -gt 1){
        $DxState
    } elseif ($NoExpand) {
        [PSCustomObject]@{
            $ExpandProperty = $DxState.$ExpandProperty
        }
    } else {
        $DxState | Select-Object -ExpandProperty $ExpandProperty
    }
}
