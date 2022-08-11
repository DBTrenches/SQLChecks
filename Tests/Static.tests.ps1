
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
