function Get-FixedSizeFileGroups {
    [cmdletbinding()]Param(
         [parameter(Mandatory=$true)][string]$ServerInstance
        ,$WhitelistFilegroups # optional array or comma-delim string
    )

    $WLFGNames=@()
    if($WhitelistFilegroups -ne $null){$WLFGNames+=$WhitelistFilegroups.Split(",")}

    $query=@"
select database_id
    ,[file_id]
    ,[type]
    ,[type_desc]
    ,[state]
    ,state_desc
    ,growth
    ,size_mb=try_convert(float,(try_cast(size as bigint)*8192.)/power(1024,2)) 
    ,max_size
    ,[db_name]=db_name(database_id)
    ,f_name=[name]
    ,f_path=physical_name
from sys.master_files 
where growth = 0;
"@

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query) | where {
        $WLFGNames -notcontains $_.f_name
    } | Select db_name,f_name,type_desc,state_desc,size_mb,f_path | ft
}
