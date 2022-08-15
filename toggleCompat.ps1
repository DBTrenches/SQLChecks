#!/usr/bin/env pwsh

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Core','Desktop')]
    [string]
    $Edition
)
<#
.SYNOPSIS
    Make the module PS Version 5 (Desktop) or enforce 6/7 (Core) compat requirements

.DESCRIPTION
    The class [DxTagGenerator] derives IValidateSetValuesGenerator which is only available
    in PS Core. A workaround for this exists and is trivial to implement but which is bad
    Because Of Reasons. If you _really_ want to run the module in v5, execute this script.
    Execute it with `-Edition Core` to toggle back.

.LINK
    https://vexx32.github.io/2018/11/29/Dynamic-ValidateSet/

.LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.ivalidatesetvaluesgenerator
#>

Push-Location $PSScriptRoot

Remove-Module SqlChecks -Force -ErrorAction SilentlyContinue

$ParamModifier_V5 = @'
        [ArgumentCompleter({
            param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
            Get-DxTags
        })]
        [ValidateScript({ $_ -in (Get-DxTags) })]
'@
$ParamModifier_V7 = '        [ValidateSet([DxTagGenerator])]'

$Psm1_V5 = '# Add-Type (Get-Content ./SqlChecks/Classes/DxTagGenerator.cs -Raw) '
$Psm1_V7 = 'Add-Type (Get-Content ./SqlChecks/Classes/DxTagGenerator.cs -Raw) '

$Psd1_V5 = @"
    # toggle compat mode by running toggleCompat.ps1 from the repo root
    # PowerShellVersion = '6.0'
"@
$Psd1_V7 = @"
    # Required for IValidateSetValuesGenerator
    PowerShellVersion = '6.0'
"@

if('Core' -eq $Edition){
    if('Core' -ne $PSEdition){
        Write-Warning "You are setting the module compat level to PSCore in a PSDesktop session. "
    }
    Get-ChildItem SqlChecks/Functions -Recurse -File | ForEach-Object {
        $FileContent = (Get-Content $_ -Raw).Replace($ParamModifier_V5, $ParamModifier_V7)
        $FileContent.TrimEnd() | Set-Content $_
    }

    (Get-Content SqlChecks.psm1 -Raw).Replace( $Psm1_V5, $Psm1_V7).TrimEnd() | Set-Content SqlChecks.psm1 
    (Get-Content SqlChecks.psd1 -Raw).Replace( $Psd1_V5, $Psd1_V7).TrimEnd() | Set-Content SqlChecks.psd1 
}

if('Desktop' -eq $Edition){
    Get-ChildItem SqlChecks/Functions -Recurse -File | ForEach-Object {
        $FileContent = (Get-Content $_ -Raw).Replace( $ParamModifier_V7, $ParamModifier_V5)
        $FileContent.TrimEnd() | Set-Content $_
    }

    (Get-Content SqlChecks.psm1 -Raw).Replace( $Psm1_V7, $Psm1_V5).TrimEnd() | Set-Content SqlChecks.psm1
    (Get-Content SqlChecks.psd1 -Raw).Replace( $Psd1_V7, $Psd1_V5).TrimEnd() | Set-Content SqlChecks.psd1 
}

Pop-Location
