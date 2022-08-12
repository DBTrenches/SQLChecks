
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Core','Desktop')]
    [string]
    $Edition
)

Push-Location $PSScriptRoot

Remove-Module SqlChecks -Force -ErrorAction SilentlyContinue

$ParamModifier_V5 = '        [ValidateSet([DxTagGenerator])]'
$ParamModifier_V7 = @'
        [ArgumentCompleter({
            param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
            Get-DxTags
        })]
        [ValidateScript({ $_ -in (Get-DxTags) })]
'@

$Psm1_V5 = '# Add-Type (Get-Content ./SqlChecks/Classes/DxTagGenerator.cs -Raw) '
$Psm1_V7 = 'Add-Type (Get-Content ./SqlChecks/Classes/DxTagGenerator.cs -Raw) '

if('Core' -eq $Edition){
    if('Core' -ne $PSEdition){
        Write-Warning "You are setting the module compat level to PSCore in a PSDesktop session. "
    }
    Get-ChildItem SqlChecks/Functions -Recurse -File | ForEach-Object {
        $FileContent = (Get-Content $_ -Raw).Replace($ParamModifier_V5, $ParamModifier_V7)
        $FileContent.TrimEnd() | Set-Content $_
    }

    (Get-Content SqlChecks.psm1 -Raw).Replace( $Psm1_V5, $Psm1_V7).TrimEnd() | Set-Content SqlChecks.psm1 
}

if('Desktop' -eq $Edition){
    Get-ChildItem SqlChecks/Functions -Recurse -File | ForEach-Object {
        $FileContent = (Get-Content $_ -Raw).Replace( $ParamModifier_V7, $ParamModifier_V5)
        $FileContent.TrimEnd() | Set-Content $_
    }

    (Get-Content SqlChecks.psm1 -Raw).Replace( $Psm1_V7, $Psm1_V5).TrimEnd() | Set-Content SqlChecks.psm1
}

Pop-Location
