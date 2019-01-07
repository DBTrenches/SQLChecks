Function Get-DatabaseMailStatus {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $query = @"
EXEC msdb.dbo.sysmail_help_status_sp
"@

    (Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query) | ForEach-Object {
		[pscustomobject]@{
			Status      = $_.Status
		}
	}	
}