Function Get-ReadWriteDatabases {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance
    )

    $query = @"
    select      d.[name] as DatabaseName
           ,databasepropertyex(d.name, 'Updateability') as Updateability
           ,d.state_desc as StateDesc
           ,d.recovery_model_desc as RecoveryModel
    from        sys.databases as d
    where       databasepropertyex(d.name, 'Updateability') = 'READ_WRITE';
"@


        
    $DBOutput = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query -QueryTimeout 60
    return $DBOutput

    
}