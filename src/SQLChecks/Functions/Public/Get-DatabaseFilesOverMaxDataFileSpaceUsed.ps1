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

        , [Parameter(ParameterSetName = "Values", Mandatory = $false)]
        [bool]
        $CalculateUsingMaxSize = 0

        , [string]
        $Database

        , [Parameter(ParameterSetName = "Values", Mandatory = $false)]
        [pscredential]
        $TargetCredential

        , [Parameter(ParameterSetName = "Values", Mandatory = $false)]
        $AzureDBCertificateAuth
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $TargetCredential = $Config.TargetCredential
        $AzureDBCertificateAuth = $Config.AzureDBCertificateAuth

        if($Config.MaxDataFileSize){
            $MaxDataFileSpaceUsedPercent = $Config.MaxDataFileSize.SpaceUsedPercent
            $WhitelistFiles = $Config.MaxDataFileSize.WhitelistFiles
            $CalculateUsingMaxSize = $Config.MaxDataFileSize.CalculateUsingMaxSize
        }

        #Support AzureDB configs
        else {
            $MaxDataFileSpaceUsedPercent = $Config.AzureDBMaxDataFileSize.SpaceUsedPercent
            $WhitelistFiles = $Config.AzureDBMaxDataFileSize.WhitelistFiles
            $CalculateUsingMaxSize = $Config.AzureDBMaxDataFileSize.CalculateUsingMaxSize
        }
    }

    $query = @"
select  a.name  [FileName],
        fg.name [FileGroup],
        c.SpaceUsed,
        c.SpaceUsedByMaxSize,
        c.DBFile
from    sys.database_files a
left join sys.filegroups fg ON a.data_space_id = fg.data_space_id
cross apply (
    select  (FILEPROPERTY(a.name, 'SPACEUSED')  /  (a.size * 1.0)  ) * 100 as SpaceUsed
            ,(FILEPROPERTY(a.name, 'SPACEUSED')  /  (a.max_size * 1.0)  ) * 100 as SpaceUsedByMaxSize
            ,'$Database.'+a.name as DBFile
) as c
WHERE   a.type != 1

"@

    if ($CalculateUsingMaxSize){
        $query += @"
and     c.SpaceUsedByMaxSize > $MaxDataFileSpaceUsedPercent
;
"@
    }

    else {
        $query += @"
and     c.SpaceUsed > $MaxDataFileSpaceUsedPercent
;
"@
    }

    if ($AzureDBCertificateAuth) {

        try {


            $conn = New-AzureSQLDbConnectionWithCert -AzureSQLDBServerName $ServerInstance `
                -DatabaseName $Database `
                -TenantID $AzureDBCertificateAuth.TenantID `
                -ClientID $AzureDBCertificateAuth.ClientID `
                -FullCertificatePath $AzureDBCertificateAuth.FullCertificatePath

            #Using Invoke-Sqlcmd2 to be able to pass in an existing connection
            $DBFiles = Invoke-Sqlcmd2 -SQLConnection $conn -query $query -ErrorAction Stop
            $conn.Close()

        }
        catch {

            if ($conn) {
                $conn.Close()

            }
        }
    
    }

    elseif ($TargetCredential) {
        $DBFiles = Invoke-Sqlcmd -ServerInstance $ServerInstance `
            -query $query `
            -Database $Database `
            -Credential $TargetCredential `
            -ErrorAction Stop
    }

    else {
        $DBFiles = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $Database -ErrorAction Stop
    }


    $DBFiles | Where-Object {
        $WhitelistFiles -notcontains $_.DBFile
    } | ForEach-Object {
        [pscustomobject]@{
            Database  = $Database
            FileName  = $_.FileName
            SpaceUsed = $_.SpaceUsed
        }
    }
}