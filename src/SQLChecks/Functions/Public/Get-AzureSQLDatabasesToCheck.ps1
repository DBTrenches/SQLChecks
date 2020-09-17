Function Get-AzureSQLDatabasesToCheck {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [string]
        $ServerInstance,

        [string[]]
        $ExcludedDatabases,

        [switch]
        $IncludeReadOnly,

        [Parameter(Mandatory = $false)]
        [pscredential]
        $TargetCredential,

        [Parameter(Mandatory = $false)]
        $AzureDBCertificateAuth

    )

    $query = @"
    select  d.name as DatabaseName
            ,d.is_read_only as IsReadOnly
    from    sys.databases as d
    where   d.state_desc = 'ONLINE';

"@


    if ($AzureDBCertificateAuth) {

        try {
     
            $conn = New-AzureSQLDbConnectionWithCert -AzureSQLDBServerName $ServerInstance `
                -DatabaseName "master" `
                -TenantID $AzureDBCertificateAuth.TenantID `
                -ClientID $AzureDBCertificateAuth.ClientID `
                -FullCertificatePath $AzureDBCertificateAuth.FullCertificatePath
    
            #Using Invoke-Sqlcmd2 to be able to pass in an existing connection
            $queryResults = Invoke-Sqlcmd2 -SQLConnection $conn -query $query -ErrorAction Stop
            $conn.Close()
    
        }
        catch {
    
            if ($conn) {
                $conn.Close()
    
            }

            Write-Error "Error Message: $_.Exception.Message"
        }
            
    }
    
    elseif ($TargetCredential) {
        try {

            $queryResults = Invoke-Sqlcmd -ServerInstance $ServerInstance `
                -query $query `
                -Database master `
                -Credential $TargetCredential `
                -ErrorAction Stop
        }
        catch {

            Write-Error "Error Message: $_.Exception.Message"
        }
        
    }
    
    else {
        Write-Error "Get-AzureSQLDatabasesToCheck: Provide AzureDBCertificateAuth or TargetCredential parameters to connect to Azure SQL DB"
        return
    }

    $queryResults | Sort-Object -Property DatabaseName | ForEach-Object {
        if ($ExcludedDatabases -contains $_.DatabaseName) {
            return
        }

        if (-not $IncludeReadOnly -and $_.IsReadOnly) {
            return
        }

        else {
            $_.DatabaseName
        }
    }


}
