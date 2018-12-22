Function Set-SpConfigValue {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [string]
        $ServerInstance,

        [parameter(Mandatory = $true)]
        [string]$ConfigName,

        [parameter(Mandatory = $true)]
        [string]
        $Value
    )

    $query = @"
declare @isAdvanced bit
        ,@showAdvanced bit;

select  @isAdvanced = c.is_advanced
from    sys.configurations as c
where   c.name = '$ConfigName';

select  @showAdvanced = cast(c.value_in_use as bit)
from    sys.configurations as c
where   c.name = 'Show Advanced Options';

if @showAdvanced = 0 and @isAdvanced = 1
begin
    exec sp_configure 'Show Advanced Options', 1;
    reconfigure;
end

exec sp_configure '$ConfigName', '$Value';
reconfigure;

if @showAdvanced = 0 and @isAdvanced = 1
begin
    exec sp_configure 'Show Advanced Options', 0;
    reconfigure;
end
"@

    Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query
}