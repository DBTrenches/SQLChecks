#Requires -Modules @{ModuleName = 'Pester';ModuleVersion = '5.0';Guid = 'a699dea5-2c73-4616-a270-1f7abb777e71';}

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
Param()

BeforeDiscovery {
    Push-Location $PSScriptRoot/..
}

AfterAll {
    Pop-Location
}

Describe "DxTag CS class file should be sorted " -Tag Sorted {
    BeforeAll {
        [Collections.ArrayList]$ClassFile = Get-Content SqlChecks/Classes/DxTagGenerator.cs
        $Start = $ClassFile.IndexOf("        {") + 1
        $End = $ClassFile.IndexOf("        };") - 1
        $Array = $ClassFile[$Start .. $End] | ForEach-Object {$_ -replace '"' -replace ',' -replace ' '}
        $SortedArray = $Array | Sort-Object
    }
    It "Tag names in the CS class file should be in alphbetical order. " {
        Compare-Object $Array $SortedArray -SyncWindow 0 | Should -BeNullOrEmpty
    }
}

Describe "DxTag PS class file should be sorted " -Tag Sorted {
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
    It "Tag names in the CS class file should be in alphbetical order. " {
        Compare-Object $Array $SortedArray -SyncWindow 0 | Should -BeNullOrEmpty
    }
}

Describe "All files should have consistent start and end whitespace. " -Tag WhiteSpace {
    BeforeDiscovery {
        $FileCollection = Get-ChildItem -Recurse -File | ForEach-Object {
            # skip empty files
            if(Get-Content $_ -Raw){
                [PSCustomObject]@{
                    Path = Resolve-Path $_ -Relative
                    Raw = Get-Content $_ -Raw
                    Trim = (Get-Content $_ -Raw).Trim()
                }
            }
        }
    }

    Context "<_.Path>" -ForEach $FileCollection {
        It "Has consistent line endings" {
            $_.Raw | Should -Be ($_.Trim + [Environment]::NewLine)
        }
    }
}
