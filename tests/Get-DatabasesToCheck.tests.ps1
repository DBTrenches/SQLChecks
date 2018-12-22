Import-Module $PSScriptRoot\..\src\SQLChecks -Force

# Can't mock Invoke-SqlCmd if we're not in module scope - ultimately invoked in a 
# private function (Get-CachedScriptBlockResult)
InModuleScope -ModuleName SQLChecks {
    # FakeServer has:
    # - A few standalone databases
    # - Primary replica for AG1
    # - Secondary replica for AG2
    $fakeServer = @(
        ("master", $false, $false, ""),
        ("model", $false, $false, ""),
        ("tempdb", $false, $false, ""),
        ("msdb", $false, $false, ""),
        ("standalonedb1", $false, $false, ""),
        ("standalonedb2", $false, $false, ""),
        ("ag1db1", $true, $true, "ag1"),
        ("ag1db2", $true, $true, "ag1"),
        ("ag2db1", $true, $false, "ag2"),
        ("ag2db2", $true, $false, "ag2")
    )

    Describe "Get-DatabasesToCheck" {
        BeforeAll {
            Remove-SQLChecksCache
        }

        Context "FakeServer instance" {
            Mock -CommandName Invoke-SqlCmd -MockWith {
                return $fakeServer | ForEach-Object {
                    [PSCustomObject]@{
                        DatabaseName                = $_[0]
                        IsAvailabilityGroupDatabase = $_[1]
                        IsPrimaryReplica            = $_[2]
                        AvailabilityGroup           = $_[3]
                    }
                }
            }

            $databases = Get-DatabasesToCheck -ServerInstance "localhost"
            It "should include all system databases" {
                "master" | Should -BeIn $databases
                "model" | Should -BeIn $databases
                "msdb" | Should -BeIn $databases
                "tempdb" | Should -BeIn $databases
            }

            $databases = Get-DatabasesToCheck -ServerInstance "localhost" -ExcludeSystemDatabases
            It "ExcludeSystemDatabases removes system databases" {
                "master" | Should -Not -BeIn $databases
                "model" | Should -Not -BeIn $databases
                "msdb" | Should -Not -BeIn $databases
                "tempdb" | Should -Not -BeIn $databases
            }
      
            $databases = Get-DatabasesToCheck -ServerInstance "localhost"
            It "should include standalonedb1 and standalonedb2 by default" {
                "standalonedb1" | Should -BeIn $databases
                "standalonedb2" | Should -BeIn $databases
            }

            $databases = Get-DatabasesToCheck -ServerInstance "localhost" -ExcludedDatabases "standalonedb1"
            It "should remove standalonedb1 when passed to ExcludedDatabases" {
                "standalonedb1" | Should -Not -BeIn $databases
                "standalonedb2" | Should -BeIn $databases
            }

            $databases = Get-DatabasesToCheck -ServerInstance "localhost" -ExcludedDatabases "standalonedb1", "standalonedb2"
            It "should remove both standalone databases when both are passed to ExcludedDatabases" {
                "standalonedb1" | Should -Not -BeIn $databases
                "standalonedb2" | Should -Not -BeIn $databases
            }

            $databases = Get-DatabasesToCheck -ServerInstance "localhost"
            It "should not include any secondary databases by default" {
                "ag2db1" | Should -Not -BeIn $databases
                "ag2db2" | Should -Not -BeIn $databases
            }

            It "should include primary ag databases by default" {
                "ag1db1" | Should -BeIn $databases
                "ag1db2" | Should -BeIn $databases
            }

            $databases = Get-DatabasesToCheck -ServerInstance "localhost" -AvailabilityGroup "ag1"
            It "should only include ag1 databases when set as AvailabilityGroup" {
                @("ag1db1", "ag1db2") | Should -Be $databases
            }

            $databases = Get-DatabasesToCheck -ServerInstance "localhost" -ExcludePrimary
            It "should not contain ag1 databases when ExcludePrimary is specified" {
                "ag1db1" | Should -Not -BeIn $databases
                "ag1db2" | Should -Not -BeIn $databases
            }

            It "should include standalonedbs when ExcludePrimary is specified" {
                "standalonedb1" | Should -BeIn $databases
                "standalonedb2" | Should -BeIn $databases
            }

            $databases = Get-DatabasesToCheck -ServerInstance "localhost" -ExcludeLocal
            It "should not include standalonedbs when ExcludeLocal is specified" {
                "standalonedb1" | Should -Not -BeIn $databases
                "standalonedb2" | Should -Not -BeIn $databases
            }
        }
    }
}