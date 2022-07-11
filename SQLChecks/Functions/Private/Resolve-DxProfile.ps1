
function Resolve-DxProfile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ProfileName
    )

    $DxProfileConfig.$ProfileName
}