Function Get-DatabaseFilesOverMaxDataFileSpaceUsed {
    [cmdletbinding()]
    Param(
        [string]
        $ServerInstance,
        
        [int]
        $MaxDataFileSpaceUsedPercent,
        
        [string[]]
        $WhitelistFiles,
        
        [string]
        $Database
    )
    
    $WhitelistString = "''"
    if($WhitelistFiles -ne $null)
    {
        $WhitelistString = "'$($WhitelistFiles -join "','")'"
    }
    
    $query = @"
select  a.name  [FileName],
        fg.name [FileGroup], 
        c.SpaceUsed
from    sys.database_files a
left join sys.filegroups fg ON a.data_space_id = fg.data_space_id
cross apply (
    select  (FILEPROPERTY(a.name, 'SPACEUSED')  /  (a.size * 1.0)  ) * 100 as SpaceUsed
            ,'$Database.'+a.name as DBFile
) as c
WHERE   a.type != 1
and     c.DBFile not in ($WhitelistString)
and     c.SpaceUsed > $MaxDataFileSpaceUsedPercent;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database | ForEach-Object {
        [pscustomobject]@{
            Database = $Database
            FileName = $_.FileName
            SpaceUsed = $_.SpaceUsed
        }
    }
}

