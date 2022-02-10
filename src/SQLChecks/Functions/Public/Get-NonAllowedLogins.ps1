Function Get-NonAllowedLogins {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [string[]]
        $Domains

        , [Parameter(ParameterSetName = "Values")]
        [string[]]
        $DomainWhitelist

    )

    $QueryResults=@();
    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $Domains = $Config.CustomCheck_NonAllowedLogins.Domains
        $DomainWhitelist = $Config.CustomCheck_NonAllowedLogins.DomainWhitelist
    }
    foreach ($Domain in $Domains) {
        $query = "select sp.name as Login FROM sys.server_principals sp where sp.name like '$Domain\%'"
        $QueryResult = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "Master" -QueryTimeout 0 -Query $query | Where-Object {
            $DomainWhitelist -notcontains $_.Login } | ForEach-Object {
            [pscustomobject]@{
                Login = $_.Login
            }
        }
        $QueryResults += $QueryResult
    }

    return $QueryResults
}