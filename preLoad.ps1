
foreach($moduleName in @('dbatools','Invoke-SqlCmd2')){
    if($null -eq (Get-Module $moduleName -ListAvailable)){
        Write-Warning "Module ${moduleName} is required. "

        while($reponse -NotIn @('Y','N')){
            $reponse = Read-Host "[Y|N] Would you like to install module ${moduleName}? "
        }

        switch ($response) {
            'Y' { Install-Module $moduleName }
            'N' { Write-Error "Required module ${moduleName} not installed. "}
        }

        $reponse = $null
    }
}

if($null -eq (Get-Module Pester -ListAvailable | Where-Object Version -ge '5.0')){
    Write-Warning "Module Pester v5 is required. "

    while($reponse -NotIn @('Y','N')){
        $reponse = Read-Host "[Y|N] Would you like to install module Pester v5? "
    }

    switch ($response) {
        'Y' { Install-Module Pester -Force -MinimumVersion '5.0' }
        'N' { Write-Error "Required module Pester v5 not installed. "}
    }

    $reponse = $null
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
