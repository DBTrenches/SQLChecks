Function Get-Sysadmins {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        ,[Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
select principal.name
from sys.server_principals as principal
join sys.server_role_members as roleMembers
on roleMembers.member_principal_id = principal.principal_id
join sys.server_principals as serverRole
on serverRole.principal_id = roleMembers.role_principal_id
and serverRole.is_fixed_role = 1
where serverRole.name = 'sysadmin'
"@

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query) |
        ForEach-Object {
        [string]$_.name
    }
}