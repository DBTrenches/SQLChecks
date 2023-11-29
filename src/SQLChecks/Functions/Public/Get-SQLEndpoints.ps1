Function Get-SQLEndpoints {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [string[]] $SQLEndpoints
   
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $SQLEndpoints = $Config.SQLEndpoints
    }

    if (!$SQLEndpoints) {
        $SQLEndpoints = @()
    }

    $query = @"
select  e.[name] as EndpointName
from    sys.endpoints as e
where   e.state_desc = 'STARTED';
"@

    $endpoints = @(Invoke-SQLCMD -TrustServerCertificate -ServerInstance $serverInstance -Query $query -Database master | Select-Object -ExpandProperty EndpointName)
    $SQLEndpoints | Where-Object { $endpoints -notcontains $_ }
}