Function Get-UnconfiguredSQLAgentAlerts {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [string[]]
        $ExcludeAlert
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $ExcludeAlert = $Config.CheckUnconfiguredSQLAgentAlerts.ExcludeAlert
    }

    $query = @"
select  [name]
        ,[enabled]
        ,[has_notification]
from msdb.dbo.sysalerts
where [enabled] = 0 or [has_notification] = 0;
"@

    (Invoke-SQLCMD -TrustServerCertificate -ServerInstance $ServerInstance -Query $query) | Where-Object {
        $ExcludeAlert -notcontains $_.name
      } | ForEach-Object {
        [pscustomobject]@{
            Name      = $_.name
            Enabled   = $_.enabled
            HasNotification = $_.has_notification
        }
    }
}