Function Get-LastIntegrityCheck {
    [cmdletbinding()]
    Param(
    [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
    $Config

    , [Parameter(ParameterSetName = "Values")]
    [string]
    $ServerInstance

    , [Parameter(ParameterSetName = "Values")]
    [string]
    $TargetRestoredBackupServer

    , [Parameter(ParameterSetName = "Values")]
    [string]
    $LogHistoryDatabase

    , [Parameter(ParameterSetName = "Values")]
    [Int[]]
    $maxHours

    , [Parameter(Mandatory = $true)]
    [string]
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

    $maxHours = $Config.CustomCheck_LastGoodIntegrityCheck.MaxHoursSinceLastGoodIntegrityCheck
    $targetRestoredBackupServer = $Config.CustomCheck_LastGoodIntegrityCheck.TargetRestoredBackupServer
    $logHistoryDatabase = $Config.CustomCheck_LastGoodIntegrityCheck.LogHistoryDatabase

  }

    $query = @"
exec Utility.GetLastIntegrityCheck @HoursSinceLastGoodIntegrityCheck = ${maxHours}, @TargetRestoreServer = '${targetRestoredBackupServer}', @DataBase = '${Database}'
"@


  if ($AzureDBCertificateAuth) {

    try {


      $conn = New-AzureSQLDbConnectionWithCert -AzureSQLDBServerName $ServerInstance `
        -DatabaseName $LogHistoryDatabase `
        -TenantID $AzureDBCertificateAuth.TenantID `
        -ClientID $AzureDBCertificateAuth.ClientID `
        -FullCertificatePath $AzureDBCertificateAuth.FullCertificatePath

      #Using Invoke-Sqlcmd2 to be able to pass in an existing connection
      $LastIntegrityChecks = Invoke-Sqlcmd2 -SQLConnection $conn -query $query -QueryTimeout 0 -ErrorAction Stop
      $conn.Close()

    }
    catch {

      if ($conn) {
        $conn.Close()

      }
    }
  
  }

  elseif ($TargetCredential) {
    $LastIntegrityChecks = Invoke-Sqlcmd -ServerInstance $ServerInstance `
      -query $query `
      -QueryTimeout 0 `
      -Database $LogHistoryDatabase `
      -Credential $TargetCredential `
      -ErrorAction Stop
  }

  else {
    $LastIntegrityChecks = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $LogHistoryDatabase -QueryTimeout 0 -ErrorAction Stop
  }

  $LastIntegrityChecks  | ForEach-Object {
    [PSCustomObject]@{
      Database          = $_.DBName
      LastIntegrityCheckFinishDate = $_.LastIntegrityCheckFinishDate
    }
  }
}

