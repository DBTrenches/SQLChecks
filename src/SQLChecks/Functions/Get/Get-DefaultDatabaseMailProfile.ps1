Function Get-DefaultDatabaseMailProfile {
    [cmdletbinding()]
    Param(
        [string] $ServerInstance
    )

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