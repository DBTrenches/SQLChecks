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
    
    $ReturnObject.Name = $InputObject.Name
    $ReturnObject.ConnectionString = $InputObject.ConnectionString

    $Alerts = foreach($node in $InputObject.SqlAgent.Alerts){
        $DxTemplateConfig.SqlAgent.Alerts.$node
    }

    $Operators = foreach($node in $InputObject.SqlAgent.Operators){
        $DxTemplateConfig.SqlAgent.Operators.$node
    }

    $ReturnObject.SqlAgent.Alerts = $Alerts
    $ReturnObject.SqlAgent.Operators = $Operators

    $ReturnObject
}