function Get-FixedSizeFiles {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true)]
        [string]
        $ServerInstance,

        [string]
        $Database,

        [string[]]
        $WhitelistFiles # optional array or comma-delim string
    )

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
and type_desc <> 'FILESTREAM'
and database_id = db_id();
"@

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query) | Where-Object {
        $WhitelistFiles -notcontains $_.f_name
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
