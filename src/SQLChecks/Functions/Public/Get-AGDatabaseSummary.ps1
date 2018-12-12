Function Get-AGDatabaseSummary {
  [cmdletbinding()]
  Param(
      [Parameter(ParameterSetName="Config",ValueFromPipeline=$true,Position=0)]
      $Config

      ,[Parameter(ParameterSetName="Values")]
      $ServerInstance

      ,[parameter(ParameterSetName="Values")]
      [string]
      $AvailabilityGroup
  )

  if($PSCmdlet.ParameterSetName -eq "Config") {
      $ServerInstance = $Config.ServerInstance
      $AvailabilityGroup = $Config.AvailabilityGroup
  }

  Get-AGDatabaseReplicaState -ServerInstance $ServerInstance -AvailabilityGroup $AvailabilityGroup
}