function Get-DxState {
<#
.SYNOPSIS
    Runs the SqlLibrary query for `$Tag` against a server and return the current state. 

.DESCRIPTION
    Every valid $Tag has a corresponding entry at $DxSqlLibrary.$Tag.QueryText. 
    This Function retrieves the corresponding query and executes it against the
    given $SqlInstance. Invoke-SqlCmd2 is used because in testing it was found to
    have far better performance than Invoke-DbaQuery when re-using connections. 
    Use of the -Database parameter necessarily establishes a new connection object
    with a different database context for each given 

.PARAMETER Database
    String array of Database names against which to execute the $Tag'd query. 
    MUST be a list of databases that exist on the server. Resolve valid arrays
    for this parameter with calls to the `Get-DxDatabasesToCheck` function. 
    Omitting this parameter will cause the query to be executed against the 
    default database context once. Including this parameter will append a 
    NoteProperty named $_._Database to the returned resultset naming the 
    database from which that DataRow object was retrieved. 
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([DxTagGenerator])]
        [string]$Tag,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [DbaInstance]$SqlInstance = $DxEntityLibrary[$DxDefaults.EntityName].ConnectionString,

        [Parameter()]
        [string[]]$Database
    )

    $DxQuery = Get-DxQuery -Tag $Tag
        
    $DxState = if($Database) {
        foreach($db in $Database) {
            Invoke-SqlCmd2 -Query $DxQuery -ServerInstance $SqlInstance -Database $db | 
                Select-Object *, @{Name="_Database";Expression={$db}}
        }
    } else {
        Invoke-SqlCmd2 -Query $DxQuery -ServerInstance $SqlInstance
    }

    $DxState = $DxState | Select-Object * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors

    if(0 -eq $DxState.Count){
        Write-Verbose "Empty resultset for [$Tag] query against [$SqlInstance]"
    }

    $DxState
}
