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
    $ReturnObject.Security.SysAdmins = $SysAdmins
    
    $NumErrorLogs = if($DxTemplateConfig.Management.NumErrorLogs){
        $DxTemplateConfig.Management.NumErrorLogs
        # https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/scm-services-configure-sql-server-error-logs
    } else { 6 }
    $ReturnObject.Management.NumErrorLogs = $NumErrorLogs 
    
    $Xevents = foreach($node in $InputObject.Management.Xevents){
        $DxTemplateConfig.Management.Xevents.$node
    }
    $ReturnObject.Management.Xevents = $Xevents
    
    $SysConfigurations = foreach($node in $InputObject.Service.SysConfigurations){
        $DxTemplateConfig.Service.SysConfigurations.$node
    }
    $ReturnObject.Service.SysConfigurations = $SysConfigurations
    
    $TempDBConfiguration = $DxTemplateConfig.Service.TempDBConfiguration.$node
    $ReturnObject.Service.TempDBConfiguration = $TempDBConfiguration
    
    $TraceFlags = foreach($node in $InputObject.Service.TraceFlags){
        $DxTemplateConfig.Service.TraceFlags.$node
    }
    $ReturnObject.Service.TraceFlags = $TraceFlags

    $Alerts = foreach($node in $InputObject.SqlAgent.Alerts){
        $DxTemplateConfig.SqlAgent.Alerts.$node
    }
    $ReturnObject.SqlAgent.Alerts = $Alerts

    $Operators = foreach($node in $InputObject.SqlAgent.Operators){
        $DxTemplateConfig.SqlAgent.Operators.$node
    }
    $ReturnObject.SqlAgent.Operators = $Operators

    return $ReturnObject
}