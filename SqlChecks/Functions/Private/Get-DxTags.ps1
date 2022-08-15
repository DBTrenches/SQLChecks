function Get-DxTags {
<#
.SYNOPSIS
    Only used for PS <= 5.0 compat at this time

.DESCRIPTION
    See toggleCompat.ps1 in the root of the repo. 
    This function is only needed when running the 
    module in PS Desktop compat mode. 
#>
    '_Utility.select1'
    'Databases.DuplicateIndexes'
    'Databases.Files.SpaceUsed'
    'Databases.IdentityColumnLimit'
    'Databases.OversizedIndexes'
    'Management.DbMail.DefaultProfile'
    'Management.NumErrorLogs'
    'Management.Xevents'
    'Security.SysAdmins'
    'Service.SysConfigurations'
    'Service.TempDbConfiguration'
    'Service.TraceFlags'
    'SqlAgent.Alerts'
    'SqlAgent.JobSchedules.Disabled'
    'SqlAgent.JobSchedules.NoneActive'
    'SqlAgent.Operators'
    'SqlAgent.Status'
}
