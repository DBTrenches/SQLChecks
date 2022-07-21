function Resolve-DxServerProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $InputObject
    )

    if($InputObject.Scope -ne 'Server'){
        Write-Error "Input scope must be server. Supplied scope was '$($InputObject.Scope)'"
        return
    }

    $ReturnObject = $DxTemplateConfig.Class.Server

    # TODO: handle for duplicate/conflicting inputs

    $SysAdmins = foreach($node in $InputObject.Security.SysAdmins){
        $DxTemplateConfig.Security.SysAdmins.$node
    }

    $NumErrorLogs = if($DxTemplateConfig.Management.NumErrorLogs){
        $DxTemplateConfig.Management.NumErrorLogs
        # https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/scm-services-configure-sql-server-error-logs
    } else { 6 }
    $Xevents = foreach($node in $InputObject.Management.Xevents){
        $DxTemplateConfig.Management.Xevents.$node
    }

    $SysConfigurations = foreach($node in $InputObject.Service.SysConfigurations){
        $DxTemplateConfig.Service.SysConfigurations.$node
    }
    $TempDBConfiguration = $DxTemplateConfig.Service.TempDBConfiguration.$node
    $TraceFlags = foreach($node in $InputObject.Service.TraceFlags){
        $DxTemplateConfig.Service.TraceFlags.$node
    }
    

    $Alerts = foreach($node in $InputObject.SqlAgent.Alerts){
        $DxTemplateConfig.SqlAgent.Alerts.$node
    }
    $Operators = foreach($node in $InputObject.SqlAgent.Operators){
        $DxTemplateConfig.SqlAgent.Operators.$node
    }

    $ReturnObject.Security.SysAdmins = $SysAdmins

    $ReturnObject.Management.NumErrorLogs = $NumErrorLogs 
    $ReturnObject.Management.Xevents = $Xevents
    
    $ReturnObject.Service.SysConfigurations = $SysConfigurations
    $ReturnObject.Service.TempDBConfiguration = $TempDBConfiguration
    $ReturnObject.Service.TraceFlags = $TraceFlags

    $ReturnObject.SqlAgent.Alerts = $Alerts
    $ReturnObject.SqlAgent.Operators = $Operators

    return $ReturnObject
}