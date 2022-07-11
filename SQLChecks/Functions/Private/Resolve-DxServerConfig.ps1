function Resolve-DxServerConfig {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [object]$Server,

        [Parameter()]
        [object]$DxProfile
    )

    $ReturnObject = $DxTemplateConfig.Class.Server
    

    foreach(
        $node in @(
            'Databases'
            'Security'
            'ServerObjects'
            'AvailabilityGroups'
            'Management'
            'SqlAgent'
        )
    ){
        $ReturnObject.$node = $DxProfile.$node
    }
    
    # foreach($override in $Server.Override.GetEnumerator().Name){
    #     $Server.$override
    # }
    

    # foreach($alert in $Server.Override.SqlAgent.Alerts.EnabledAlerts){
    #     switch($alert.'@Action'){
    #         "Add" {$ReturnObject.SqlAgent.EnabledAlerts += $alert.Name}
    #         "Remove" {$ReturnObject.SqlAgent.EnabledAlerts = $Server.SqlAgent.EnabledAlerts | Where-Object { $_ -ne $alert.Name}}
    #     }
    # }



    return $ReturnObject
}
