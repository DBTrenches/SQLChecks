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

    Invoke-SQLCMD -TrustServerCertificate -ServerInstance $serverInstance -Query $query -Database msdb |
        Select-Object -ExpandProperty DatabaseName |
        Where-Object { $ExcludeDatabases -notcontains $_ }
}