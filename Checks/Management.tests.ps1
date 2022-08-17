#Requires -Modules @{ModuleName='SqlChecks';ModuleVersion='2.0';Guid='998f41a0-c4b4-4ec5-9e11-cb807d98d969'}

# PsScriptAnalyzer reports false positive for $vars defined in `Discovery` not used until `It`
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

[CmdletBinding()]
Param(
    [string]$EntityName = $DxDefaults.EntityName
)

BeforeAll {
    if ($PSBoundParameters.Keys -contains 'EntityName') {
        Write-Verbose "User-selected entity will be used. "
    }
    else {
        Write-Verbose "Default entity will be used. "
    }
    Write-Host "Selected entity is '$EntityName' "
    Write-Host "The connection string to be used is '$($DxEntityLibrary.$EntityName.ConnectionString)' "
}

BeforeDiscovery {
    . $PSScriptRoot/Set-DxPesterVariables.ps1
}

BeforeAll {
    . $PSScriptRoot/Set-DxPesterVariables.ps1
}

Describe "Management.NumErrorLogs" -Tag Management.NumErrorLogs { 
    BeforeAll {
        # @Connect splat is not available to this scope
        $ServerValue = (Get-DxState Management.NumErrorLogs @Connect).NumErrorLogs
        $ConfigValue = $DxEntityLibrary.$EntityName.Management.NumErrorLogs
    }

    It "NumErrorLogs: $($DxEntityLibrary.$EntityName.Management.NumErrorLogs) " {
        $ServerValue | Should -BeExactly $ConfigValue
        $ConfigValue | Should -Not -BeNullOrEmpty
    }
}

Describe "Management.Xevents " -Tag Management.Xevents {
    BeforeDiscovery {
        $StartupXeventData = @{
            ServerData = Get-DxState Management.Xevents @Connect | Where-Object { $_.StartupState -eq $true } 
            ConfigData = $DxEntity.Management.Xevents | Where-Object { $_.StartupState -eq $true } 
        }
        $StartupXeventCollection = Join-DxConfigAndState @StartupXeventData
    }

    It "StartupXevent: <_.Name> " -ForEach $StartupXeventCollection {
        $_.ExistsInConfig | Should -BeTrue
        $_.ExistsOnServer | Should -BeTrue
    }
}

Describe "Management.DbMail.DefaultProfile " -Tag Management.DbMail.DefaultProfile {
    BeforeAll {
        $ServerState = Get-DxState Management.DbMail.DefaultProfile @Connect
    }
    It "DbMail.DefaultProfile " {
        $ServerState.IsDefault | Should -BeTrue
    }
}
