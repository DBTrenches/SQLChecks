Function Get-RunningService {
    [cmdletbinding()]
    Param(
        [Parameter(ParameterSetName = "Config", ValueFromPipeline = $true, Position = 0)]
        $Config

        , [Parameter(ParameterSetName = "Values")]
        [string]
        $ServerInstance

        , [parameter(Mandatory = $true)]
        [string]
        $ServiceName
    )

    if ($PSCmdlet.ParameterSetName -eq "Config") {
        $ServerInstance = $Config.ServerInstance
    }

    $command = {Param ($ServiceName) Get-Service -Name $ServiceName -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "Running"}}
    $Service = @(Invoke-Command -ComputerName $ServerInstance -ScriptBlock $command -ArgumentList $ServiceName)
    return $Service 
	
}