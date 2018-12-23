Import-Module $PSScriptRoot\..\src\SQLChecks -Force

# Need to mock the internal function Get-AGDatabaseReplicaState
InModuleScope -ModuleName SQLChecks {

    # One primary, one sync secondary - healthy, 2 DBs
    $healthyAG = @(
        ("inst", "healthyAG", "db1", "SYNCHRONIZED", 0, $true),
        ("inst", "healthyAG", "db2", "SYNCHRONIZED", 0, $true),
        ("inst", "healthyAG", "db1", "SYNCHRONIZED", 5, $false),
        ("inst", "healthyAG", "db2", "SYNCHRONIZED", 5, $false)
    )

    # One primary, two sync secondary, one replica with delayed redo
    $longRedoAG = @(
        ("inst", "healthyAG", "db1", "SYNCHRONIZED", 0, $true),
        ("inst", "healthyAG", "db2", "SYNCHRONIZED", 0, $true),
        ("inst", "healthyAG", "db1", "SYNCHRONIZED", 5, $false),
        ("inst", "healthyAG", "db1", "SYNCHRONIZED", 150, $false),
        ("inst", "healthyAG", "db2", "SYNCHRONIZED", 5, $false),
        ("inst", "healthyAG", "db2", "SYNCHRONIZED", 150, $false)
    )

    Describe "Get-AGDatabaseSummary" {
        Context "Healthy AG" {
            Mock -CommandName Get-AGDatabaseReplicaState -MockWith {
                return $healthyAG | ForEach-Object {
                    [PSCustomObject]@{
                        ServerInstance       = $_[0]
                        AvailabilityGroup    = $_[1]
                        DatabaseName         = $_[2]
                        SynchronizationState = $_[3]
                        RedoQueueSize        = $_[4]
                        IsPrimaryReplica     = $_[5]
                    }
                }
            }

            $databases = Get-AGDatabaseSummary -ServerInstance "localhost" -AvailabilityGroup "test"

            It "should have two databases in the summary record" {
                $databases.Count | Should -Be 2
            }

            foreach ($db in $databases) {
                It "$($db.DatabaseName) should have one synchronized secondary" {
                    $db.SynchronizedReplicas | Should -Be 1
                }

                It "$($db.DatabaseName) should report the primary is synchronized" {
                    $db.PrimarySynchronizationState | Should -Be "SYNCHRONIZED"
                }

                It "$($db.DatabaseName) should report the secondary redo" {
                    $db.LongestRedoQueue | Should -Be 5
                }
            }
        }

        Context "Long Redo AG" {
            Mock -CommandName Get-AGDatabaseReplicaState -MockWith {
                return $longRedoAG | ForEach-Object {
                    [PSCustomObject]@{
                        ServerInstance       = $_[0]
                        AvailabilityGroup    = $_[1]
                        DatabaseName         = $_[2]
                        SynchronizationState = $_[3]
                        RedoQueueSize        = $_[4]
                        IsPrimaryReplica     = $_[5]
                    }
                }
            }

            $databases = Get-AGDatabaseSummary -ServerInstance "localhost" -AvailabilityGroup "test"

            foreach ($db in $databases) {
                It "$($db.DatabaseName) should report the largest secondary redo" {
                    $db.LongestRedoQueue | Should -Be 150
                }
            }
        }
    }
}