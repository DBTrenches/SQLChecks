Function Get-SpConfigValue {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true)]
        [string]
        $ServerInstance,
        
        [parameter(Mandatory=$true)]
        [string]
        $ConfigName
    )

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
            ConfigName = $_.name
            ConfiguredValue = $_.value
            RuntimeValue = $_.value_in_use
            IsAdvanced = $_.is_advanced
        }
    }
}