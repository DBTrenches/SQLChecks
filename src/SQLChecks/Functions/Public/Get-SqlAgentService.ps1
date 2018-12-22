Function Get-SqlAgentService {
    [cmdletbinding()]
    Param (
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
select  dss.status_desc, dss.startup_type_desc
from    sys.dm_server_services as dss
where   dss.servicename like 'SQL Server Agent%'
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database master | ForEach-Object {
        [pscustomobject]@{
            Status      = $_.status_desc
            StartupType = $_.startup_type_desc
        }
    }
}