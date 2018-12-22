Function Get-SqlAgentJobsWithDisabledSchedule {
    [cmdletbinding()]
    Param (
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
select	j.job_id as JobId
    ,j.name as JobName
    ,sched.name as DisabledScheduleName
from	dbo.sysjobs as j
join	dbo.syscategories as c
on		j.category_id = c.category_id
cross apply (
select top 1 s.name
from dbo.sysjobschedules as js
join dbo.sysschedules as s
on s.schedule_id = js.schedule_id
where js.job_id = j.job_id
and s.enabled = 0
) as sched
where c.name <> 'Report Server'
"@
    Invoke-Sqlcmd -ServerInstance $serverInstance -query $query -Database msdb | ForEach-Object {
        [pscustomobject]@{
            JobId                     = $_.JobId
            JobName                   = $_.JobName
            FirstDisabledScheduleName = $_.DisabledScheduleName
        }
    }
}