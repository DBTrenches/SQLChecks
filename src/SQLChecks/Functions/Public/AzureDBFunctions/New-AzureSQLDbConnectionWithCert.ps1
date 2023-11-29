Function New-AzureSQLDbConnectionWithCert {

    <#
    Ensure AzureSQLDBServerName is fully qualified. (mydbserver.database.windows.net)
    FullCertificatePath should be in this format: Cert:\PathToCert\<CertificateThumprint>
        Example: Cert:\LocalMachine\My\1360252F5567A7A=4562063424E0DEAD9AF5
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AzureSQLDBServerName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $TenantID,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ClientID,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $FullCertificatePath

    )
  
    
    try {

        Import-Module Az.Accounts -force

        $Certificate = Get-Item $FullCertificatePath
        $CertificateThumbprint = $Certificate.Thumbprint

        Connect-AzAccount -Tenant $TenantID -ApplicationId $ClientID -CertificateThumbprint $CertificateThumbprint -ServicePrincipal| Out-Host;
        if (-not $?) {
            Write-Error "Can't connect to Azure Tenant";
            return $null;
        }
        $objectAccessToken = (Get-AzAccessToken -ResourceUrl "https://database.windows.net/");
        $accessToken = $objectAccessToken.Token;
        if ( -not $accessToken) {
            Write-Error "AccessToken is empty, can't connect to Azure SQL Database";
            return $null;
        }

        $Tok = $accessToken.Replace("Bearer ", "")


        #Create connection object
        $conn = New-Object System.Data.SqlClient.SQLConnection
        $conn.ConnectionString = "Data Source=$AzureSQLDBServerName;Initial Catalog=$DatabaseName;Connect Timeout=30;"
        if ($AppName) { $conn.ConnectionString += "Application Name=$AppName;" }
        $conn.AccessToken = $Tok

        return $conn
        
    }
    
    catch {
        Write-Error "Failed to create connection to Azure DB Server: $AzureSQLDBServerName"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }

    
    
}