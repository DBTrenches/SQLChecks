function Get-DxState {
<#
.SYNOPSIS
    Runs the SqlLibrary query for $Tag against a server and return the current state. 

.DESCRIPTION
    Every valid $Tag has a corresponding entry at $DxSqlLibrary.$Tag.QueryText. 
    This Function retrieves the corresponding query and executes it against the
    given $SqlInstance. Invoke-SqlCmd2 is used because in testing it was found to
    have far better performance than Invoke-DbaQuery when re-using connections. 
    Use of the -Database parameter necessarily establishes a new connection object
    with a different database context for each given 

.PARAMETER Database
    String array of Database names against which to execute the $Tag'd query. 
    Uses syntax similar to Ola Hallengren for excluding databases: prefixing a
    database name with a minus symbol (-) will exlude the database. This is only
    required when including the star symbol (*) which will include all databases
    on the server. Fuzzy matching is not supported at this time. If this param
    includes a database that does not exist on the server, a warning will be raised.
    If this param is not used, `master` db will be used. 
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet([DxTagGenerator])]
        [string]$Tag,

        [Parameter(Mandatory)]
        [DbaInstance]$SqlInstance,

        [Parameter()]
        [string[]]$Database
    )

    $DxQuery = Get-DxQuery -Tag $Tag

    if($PSBoundParameters.Keys -contains 'Database'){
        $AllDatabases = (Invoke-SqlCmd2 -ServerInstance $SqlInstance -Query "select [name] as [Name] from sys.databases").Name

        # NonExistentDatabases 
        $Database | Where-Object {
            ($_ -NotIn $AllDatabases) -and
            ($_ -ne "*") -and
            ($_[0] -ne '-')
        } | ForEach-Object {
            Write-Warning "Input database '$_' does not exist on SqlInstance $($SqlInstance.FullName). The entry will be excluded. "
        }

        if($Database -Contains "*"){
            $DatabaseCollection = $AllDatabases
        } else {
            $DatabaseCollection = $Database | Where-Object { $_ -In $AllDatabases }
        }

        [string[]]$ExcludeDatabases = @()
        $Database | Where-Object { $_.Substring(0,1) -eq '-' } | ForEach-Object {
            $db = $_.Substring(1)
            Write-Verbose "Database '$db' will be excluded by user preference. "
            $ExcludeDatabases += $db
        }
        $DatabaseCollection = $DatabaseCollection | Where-Object { $_ -NotIn $ExcludeDatabases }
    }

    $DxState = if($PSBoundParameters.Keys -Contains 'Database'){
        foreach($db in $DatabaseCollection) {
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
