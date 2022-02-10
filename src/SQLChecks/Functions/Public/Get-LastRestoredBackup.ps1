Function Get-LastRestoredBackup {
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

    $maxHours = $Config.CustomCheck_LastGoodRestoredBackupCheck.MaxHoursSinceLastGoodRestoredBackup
    $targetRestoredBackupServer = $Config.CustomCheck_LastGoodRestoredBackupCheck.TargetRestoredBackupServer
    $logHistoryDatabase = $Config.CustomCheck_LastGoodRestoredBackupCheck.LogHistoryDatabase

  }

    $query = @"
exec Utility.GetLastRestoredBackup @HoursSinceLastGoodRestoredBackup = ${maxHours}, @TargetRestoreServer = '${targetRestoredBackupServer}', @DataBase = '${Database}'
"@


  if ($AzureDBCertificateAuth) {

    try {


      $conn = New-AzureSQLDbConnectionWithCert -AzureSQLDBServerName $ServerInstance `
        -DatabaseName $LogHistoryDatabase `
        -TenantID $AzureDBCertificateAuth.TenantID `
        -ClientID $AzureDBCertificateAuth.ClientID `
        -FullCertificatePath $AzureDBCertificateAuth.FullCertificatePath

      #Using Invoke-Sqlcmd2 to be able to pass in an existing connection
      $LastRestoredBackups = Invoke-Sqlcmd2 -SQLConnection $conn -query $query -QueryTimeout 0 -ErrorAction Stop
      $conn.Close()

    }
    catch {

      if ($conn) {
        $conn.Close()

      }
    }
  
  }

  elseif ($TargetCredential) {
    $LastRestoredBackups = Invoke-Sqlcmd -ServerInstance $ServerInstance `
      -query $query `
      -QueryTimeout 0 `
      -Database $LogHistoryDatabase `
      -Credential $TargetCredential `
      -ErrorAction Stop
  }

  else {
    $LastRestoredBackups = Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database $LogHistoryDatabase -QueryTimeout 0 -ErrorAction Stop
  }

  $LastRestoredBackups  | ForEach-Object {
    [PSCustomObject]@{
      Database          = $_.DBName
      LastRestoredBackupFinishDate = $_.LastRestoredBackupFinishDate
    }
  }
}

