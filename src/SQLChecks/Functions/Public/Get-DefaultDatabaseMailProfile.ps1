Function Get-DefaultDatabaseMailProfile {
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

    $query = @"
select pp.profile_id
from msdb.dbo.sysmail_principalprofile as pp
where pp.principal_sid = 0x0 /* Guest */
and pp.is_default = 1
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query | ForEach-Object {
        [pscustomobject]@{
            ProfileId = $_.profile_id
        }
    }
}