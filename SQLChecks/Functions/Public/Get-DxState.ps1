function Get-DxState {
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
        $AllDatabases = (Invoke-DbaQuery -SqlInstance $SqlInstance -Query "select [name] as [Name] from sys.databases").Name

        $NonExistentDatabases = $Database | Where-Object {
            ($_ -NotIn $AllDatabases) -and
            ($_ -ne "*") 
        } 

        $NonExistentDatabases | ForEach-Object {
            Write-Warning "Input database '$_' does not exist on SqlInstance $($SqlInstance.FullName). The entry will be excluded. "
        }

        if($Database -contains "*"){
            $Database = $AllDatabases
        } else {
            $Database = $Database | Where-Object {$_ -In $AllDatabases}
        }
    }

    $DxState = if($PSBoundParameters.Keys -contains 'Database'){
        foreach($db in $Database) {
            Invoke-DbaQuery -Query $DxQuery -SqlInstance $SqlInstance -Database $db | 
                Select-Object *, @{Name="_Database";Expression={$db}}
        }
    } else {
        Invoke-DbaQuery -Query $DxQuery -SqlInstance $SqlInstance
    }

    $DxState = $DxState | Select-Object * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors

    if(0 -eq $DxState.Count){
        Write-Verbose "Empty resultset for [$Tag] query against [$SqlInstance]"
    }

    $DxState
}
