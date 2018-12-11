Param(
  $Config
)

$serverInstance = $config.ServerInstance
$availabilityGroup = $config.AvailabilityGroup

Describe "AG Instance connectivity" -Tag AGInstanceConnectivity {
  It "Can connect to $serverInstance" {
    {
      Invoke-SqlCmd -ServerInstance $serverInstance -Query "select @@servername" -Database master
    } | Should -Not -Throw
  }
}

## TODO
# Sync secondary count (synchronized) -> all DBs? or foreach DB?
