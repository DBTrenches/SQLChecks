function Resolve-DxServerConfig {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [object]$DxEntity,

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
    
    $EntityName = $DxEntity.Name

    $ReturnObject.Name = $EntityName
    $ReturnObject.ConnectionString = $DxEntity.ConnectionString

    $OverrideObject = $DxEntityConfig.$EntityName.Override

    foreach($alert in $OverrideObject.SqlAgent.Alerts){
        $Action = $alert.'@Action'
        $alert = $alert | Select-Object * -ExcludeProperty '@Action'
        switch($Action){
            "Add" {$ReturnObject.SqlAgent.Alerts += $alert}
            "Remove" {$ReturnObject.SqlAgent.Alerts = $Server.SqlAgent.Alerts | Where-Object { $_.Name -ne $alert.Name}}
        }
    }

    foreach($operator in $OverrideObject.SqlAgent.Operators){
        $Action = $operator.'@Action'
        $operator = $operator | Select-Object * -ExcludeProperty '@Action'
        switch($Action){
            "Add" {$ReturnObject.SqlAgent.Operators += $operator}
            "Remove" {$ReturnObject.SqlAgent.Operators = $Server.SqlAgent.Operators | Where-Object { $_.Name -ne $operator.Name}}
        }
    }

    return $ReturnObject
}
