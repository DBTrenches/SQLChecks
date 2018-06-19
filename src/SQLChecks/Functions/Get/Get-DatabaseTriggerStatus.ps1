Function Get-DatabaseTriggerStatus {
    [cmdletbinding()]
    Param(
        [string]
        $ServerInstance,
        
        [string]
        $TriggerName,
        
        [string]
        $Database
    )

    $query = @"
    select count(*) as TriggerCount
    from sys.triggers as t
    where t.name = '$TriggerName'
    and t.is_disabled = 0
"@

    $result = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database
    if($result.TriggerCount -eq 0) {
        $false
    } else {
        $true
    }
}