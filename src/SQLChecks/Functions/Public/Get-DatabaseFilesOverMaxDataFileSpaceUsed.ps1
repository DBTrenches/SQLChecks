Function Get-DatabaseFilesOverMaxDataFileSpaceUsed {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [int]
        $MaxDataFileSpaceUsedPercent

        , [Parameter(ParameterSetName = "Values")]
        [string[]]
        $WhitelistFiles

        , [string]
        $Database
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $MaxDataFileSpaceUsedPercent = $Config.MaxDataFileSize.SpaceUsedPercent
        $WhitelistFiles = $Config.MaxDataFileSize.WhitelistFiles
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
and     c.SpaceUsed > $MaxDataFileSpaceUsedPercent
;
"@

    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database | Where-Object {
        $WhitelistFiles -notcontains $_.FileName
    } | ForEach-Object {
        [pscustomobject]@{
            Database  = $Database
            FileName  = $_.FileName
            SpaceUsed = $_.SpaceUsed
        }
    }
}