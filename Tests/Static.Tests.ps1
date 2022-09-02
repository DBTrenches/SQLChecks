#Requires -Modules @{ModuleName = 'Pester';ModuleVersion = '5.0';Guid = 'a699dea5-2c73-4616-a270-1f7abb777e71';}

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
Param()

BeforeDiscovery {
    Push-Location $PSScriptRoot/..
}

AfterAll {
    Pop-Location
}

Describe "DxTag CS class file " -Tag ClassFile, CS {
    BeforeAll {
        [Collections.ArrayList]$ClassFile = Get-Content SqlChecks/Classes/DxTagGenerator.cs
        $Start = $ClassFile.IndexOf("        {") + 1
        $End = $ClassFile.IndexOf("        };") - 1
        $Array = $ClassFile[$Start .. $End] | ForEach-Object {$_ -replace '"' -replace ',' -replace ' '}
        $SortedArray = $Array | Sort-Object
    }
    It "Tag names should be in alphbetical order. " -Tag Sorted {
        Compare-Object $Array $SortedArray -SyncWindow 0 | Should -BeNullOrEmpty
    }
    It "There are no duplicate tags" -Tag Dupe, Duplicate {
        ($Array | Group-Object | Where-Object Count -gt 1).Name | Should -BeNullOrEmpty
    }
}

Describe "DxTag PS class file " -Tag ClassFile, PS {
    BeforeAll {
        [Collections.ArrayList]$ClassFile = Get-Content SqlChecks/Classes/DxTagGenerator.ps1
        $Start = $ClassFile.IndexOf('        $Values = @(') + 1
        $End = $ClassFile.IndexOf("        )") - 1
        $Array = $ClassFile[$Start .. $End] | ForEach-Object {
            ($_  -split '#')[0] -replace "'" -replace ' '
        } | Where-Object { 
            [bool]$_ # not null or empty
        }
        $SortedArray = $Array | Sort-Object
    }
    It "Tag names in should be in alphbetical order. " -Tag Sorted {
        Compare-Object $Array $SortedArray -SyncWindow 0 | Should -BeNullOrEmpty
    }
    It "There are no duplicate tags" -Tag Dupe, Duplicate {
        ($Array | Group-Object | Where-Object Count -gt 1).Name | Should -BeNullOrEmpty
    }
}

Describe "All files should have consistent start and end whitespace. " {
    # TODO: exclude lots, like .gitignored local config
    BeforeDiscovery {
        $FileCollection = Get-ChildItem -Recurse -File | ForEach-Object {
            # skip empty files
            if(Get-Content $_ -Raw){
                [PSCustomObject]@{
                    Path = Resolve-Path $_ -Relative
                    Raw = Get-Content $_ -Raw
                    Trim = (Get-Content $_ -Raw).Trim()
                    Name = $_.Name
                    ParentFolder = $_.Directory.Name
                }
            }
        }

        $PowerShellFunctionFileCollection = $FileCollection | Where-Object {'Functions' -eq $_.ParentFolder}
    }

    Context "<_.Path>" -ForEach $FileCollection {
        # Fix with: $FileCollection | % { Set-Content -Path $_.Path -Value $_.Trim }
        It "Has consistent line endings" -Tag WhiteSpace {
            $_.Raw | Should -Be ($_.Trim + [Environment]::NewLine)
        }

    }

    Context "<_.Path>" -ForEach $PowerShellFunctionFileCollection -Tag PowerShell {
        It "PowerShell function files should be named after the function they define" {
            $_.Raw | Should -Match "function $($_.Name -replace '.ps1')"
        }
    }
}
