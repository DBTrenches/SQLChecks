function Get-FixedSizeFiles {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true)]
        [string]
        $ServerInstance,

        [string]
        $Database,
        
        $WhitelistFiles # optional array or comma-delim string
    )

    $whitelistedFiles=@()
    if($WhitelistFiles -ne $null) {
        $whitelistedFiles+=$WhitelistFiles.Split(",")
    }

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
where growth = 0
and database_id = db_id();
"@

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query) | Where-Object {
        $whitelistedFiles -notcontains $_.f_name
    } | ForEach-Object {
        [pscustomobject]@{
            DatabaseName = $_.db_name
            FileName = $_.f_name
            FileType = $_.type_desc
            FileState = $_.state_desc
            SizeMB = $_.size_mb
            FilePath = $_.f_path
        }
    } 
}
