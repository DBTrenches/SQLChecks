Function Get-TraceFlags {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = "dbcc tracestatus"

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query) |
        ForEach-Object {
        [int]$_.TraceFlag
    }
}