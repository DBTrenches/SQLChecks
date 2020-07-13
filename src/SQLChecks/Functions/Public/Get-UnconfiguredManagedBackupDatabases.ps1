Function Get-UnconfiguredManagedBackupDatabases {
    [cmdletbinding()]
    Param (
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance
        
        , [Parameter(ParameterSetName = "Values")]
        [string[]]
        $ExcludeDatabases
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $ExcludeDatabases = $Config.UnconfiguredManagedBackups.ExcludeDatabases
    }

    $query = @"
    select  [db_name] as DatabaseName
    from    msdb.managed_backup.fn_backup_db_config(null)
    where   is_dropped = 0
    and     is_managed_backup_enabled = 0
    and     [db_name] <> 'model';
"@

 
    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database msdb | Where-Object {
        $ExcludeDatabases -notcontains $_.DatabaseName } | ForEach-Object {
        [PSCustomObject]@{
            DatabaseName = $_.DatabaseName
        }
    }
}