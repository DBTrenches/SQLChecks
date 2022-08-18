<#
.DESCRIPTION
    This script checks RequiredModules, PSVersion, and for the existence
    of `code` on the commandline (for the New-DxCheck fuinction).
    This script **LIKELY DOES NOT WORK** to pre-install modules without a 2nd
    wrapper manifest. See the blog post for a full explanation. No 2nd manifest 
    exists at this time because I'm lazy. 

.LINK
    https://tommymaynard.com/the-scriptstoprocess-and-requiredmodules-order-2018/
#>

$RequiredModules = @(
    @{
        ModuleName = 'dbatools'
        ModuleVersion = '1.1.95'
        Guid = '9d139310-ce45-41ce-8e8b-d76335aa1789'
    }
    @{
       ModuleName = 'Invoke-SqlCmd2'
       ModuleVersion = '1.6.4'
       Guid = '688f05ef-8460-496c-8600-87c53090634c'
    }
    @{
       ModuleName = 'Pester'
       ModuleVersion = '5.0'
       Guid = 'a699dea5-2c73-4616-a270-1f7abb777e71'
    }
)

foreach($module in $RequiredModules){
    if($null -eq (Get-Module $module.ModuleName -ListAvailable)){
        Write-Warning "Module $($module.ModuleName) is required. "

        while($reponse -NotIn @('Y','N')){
            $reponse = Read-Host "[Y|N] Would you like to install module $($module.ModuleName)? "
        }

        switch ($response) {
            'Y' { Install-Module $module.ModuleName -MinimumVersion $module.ModuleVersion }
            'N' { Write-Error "Required module $($module.ModuleName) not installed. "}
        }

        $reponse = $null
    }
}

if('Core' -ne $PSEdition){
    while($reponse -NotIn @('Y','N')){
        $reponse = Read-Host "[Y|N] You are running PS v5 or lower. Would you like to toggle v5 compat? "
    }

    switch ($response) {
        'Y' { toggleCompat.ps1 Desktop }
        'N' { Write-Error "You must swith to PS Core or toggle v5 compat. "}
    }

    $reponse = $null
}

#Region UserMode

if($null -eq (Get-Command code)){
    Write-Error "`code` utility not found on `$PATH. Function `New-DxCheck` invokes VSCode via the command line. "
}

# Adding new tags requires loading a fresh session. 
# Default code terminal handling preserves the environment on reload.
# Reloading integrated terminal (from the extension) does this better.
# Extension also supports [run|debug]-test-from-GUI
if('ms-vscode.powershell' -NotIn (code --list-extensions)){
    choco install vscode-powershell --yes
}

# ¿TODO: assert git config?

#EndRegion UserMode
