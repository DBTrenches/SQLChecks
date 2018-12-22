Function Get-SpConfigValue {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [parameter(Mandatory = $true)]
        [string]
        $ConfigName
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
select  c.name
        ,c.value
        ,c.value_in_use
        ,c.is_advanced
from    sys.configurations as c
where   c.name = '$ConfigName'
"@

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query) |
        ForEach-Object {
        [pscustomobject]@{
            ConfigName      = $_.name
            ConfiguredValue = $_.value
            RuntimeValue    = $_.value_in_use
            IsAdvanced      = $_.is_advanced
        }
    }
}