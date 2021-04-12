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
        # To install the latest AzureRM.profile version execute
        ####Install-Module -Name AzureRM.profile -Force -AllowClobber

        Import-Module AzureRM.profile
        $version = (Get-Module -Name AzureRM.profile).Version.toString()

        $Certificate = Get-Item $FullCertificatePath

        $adalPath = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\${version}"
        $adal = "$adalPath\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

        $resourceAppIdURI = 'https://database.windows.net/'
        $authority = 'https://login.windows.net/' + $TenantID

        $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authority)
        $CAC = [Microsoft.IdentityModel.Clients.ActiveDirectory.ClientAssertionCertificate]::new($ClientID, $Certificate)

        #Get Token
        $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $CAC)
        $Tok = $authResult.Result.CreateAuthorizationHeader()
        $Tok = $Tok.Replace("Bearer ", "")

        #Create connection object
        $conn = New-Object System.Data.SqlClient.SQLConnection
        $conn.ConnectionString = "Data Source=$AzureSQLDBServerName;Initial Catalog=$DatabaseName;Connect Timeout=30"
        $conn.AccessToken = $Tok

        $conn.Open()

        return $conn

    }

    catch {
        Write-Error "Failed to create connection to Azure DB Server: $AzureSQLDBServerName"
        Write-Error "Error Message: $_.Exception.Message"
        throw
    }
}