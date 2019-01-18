Function Get-UnconfiguredAlerts {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [Parameter(ParameterSetName = "Values")]
        [string[]]
        $ExcludeAlert
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
        $ExcludeAlert = $Config.CheckUnconfiguredAlerts.ExcludeAlert
    }

    $query = @"
SELECT [name], [enabled], [has_notification] FROM msdb.dbo.sysalerts
WHERE [enabled] = 0 OR [has_notification] = 0;
"@

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query) | Where-Object {
        $ExcludeAlert -notcontains $_.name
      } | ForEach-Object {
		[pscustomobject]@{
			Name      = $_.name
            Enabled   = $_.enabled
            Has_Notification = $_.has_notification
		}
	}	
}