
function Resolve-DxProfile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ProfileName
    )

    # unsure why I can't get this to work in [ValidateScript({})] 🤔
    if($ProfileName -NotIn $DxProfileConfig.GetEnumerator().Name){
        Write-Error "Supplied ProfileName '$ProfileName' not found in the `$DxProfileConfig collection"
    }

    $ReturnObject = $DxProfileConfig.$ProfileName

    $ReturnObject = switch($ReturnObject.Scope){
        'Server' { Resolve-DxServerProfile $ReturnObject }
        'AvailabilityGroup' { Resolve-DxAvalabilityGroupProfile $ReturnObject }
        'Database' { Resolve-DxDatabaseProfile $ReturnObject }
        default { Write-Error "blarbglebloop" }
    }

    return $ReturnObject
}
