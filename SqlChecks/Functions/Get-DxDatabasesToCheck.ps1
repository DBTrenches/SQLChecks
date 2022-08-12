Function Get-DxDatabasesToCheck {
<#
.SYNOPSIS
    Returns an array of valid database names to query. Validates input against server
    before returning. 

.DESCRIPTION
    Default behavior is to read from config in $DxEntityLibrary for a specific $Tag. 
    Each entity should have a top-level $_.DatabasesToCheck element as well as optional 
    per-$Tag $_.{$Tag}.DatabasesToExclude elements. Thus resolving both of these together
    and validating them against the corresponding $SqlInstance for this $DxEntity. 
    
    Alternately, you can supply a raw $SqlInstance and (optionally) an Ola-Hallengren
    format list of $Databases to check. This will also be validated against the server 
    before being returned. 

.PARAMETER EntityName
    Must be a valid entry from (top level hash key of) $DxEntiryLibrary

.PARAMETER Database
    String array of Database names against which to execute the $Tag'd query. 
    Uses syntax similar to Ola Hallengren for excluding databases: prefixing a
    database name with a minus symbol (-) will exlude the database. This is only
    required when including the star symbol (*) which will include all databases
    on the server. Fuzzy matching is not supported at this time. If this param
    includes a database that does not exist on the server, a warning will be raised.
    If this param is not used, `master` db will be used. @-Labels are also supported.
#>
    [CmdletBinding(DefaultParameterSetName = 'Database')]
    [Alias('gxdb')]
    Param(

        [Parameter(Mandatory, ParameterSetName = 'Entity')]
        [ValidateSet([DxTagGenerator])]
        $Tag,

        [Parameter(ParameterSetName = 'Entity')]
        [string]
        $EntityName = $DxDefaults.EntityName,

        [Parameter(ParameterSetName = 'Database')]
        [DbaInstance]
        $SqlInstance = $DxEntityLibrary[$DxDefaults.EntityName].ConnectionString,

        [Parameter(ParameterSetName = 'Database', Position = 0)]
        [string[]]
        $Database = @('*')
    )

    $DxEntity = $DxEntityLibrary.$EntityName

    [string[]]$ExcludeDatabases = @()

    $AllDatabases = (Invoke-SqlCmd2 -ServerInstance $SqlInstance -Query "select [name] as [Name] from sys.databases").Name

    switch ($PSCmdlet.ParameterSetName) { 
        'Entity' {
            $Database = $DxEntity.DatabasesToCheck
        
            if($null -eq $Database){
                Write-Warning "No config value found for '$EntityName.DatabasesToCheck'. All Databases will be used. "

                $Database = $AllDatabases
            }

            [string[]]$ExcludeDatabases = (Invoke-Expression "`$DxEntity.$Tag.ExcludedDatabases")

            $Connect = @{ ServerInstance = $DxEntity.ConnectionString }
        } 
        'Database' {
            $Connect = @{ ServerInstance = $SqlInstance }
        }
        Default { Write-Error 'Get-DxDatabasesToCheck: Unhandled exception.' }
    }

    # TODO: foreach/multi-label support
    if (($Database.Count -eq 1) -and ($Database[0].Substring(0, 1) -eq '@')) {
        $Label = $Database
        $Database = switch ($Label) {
            "@LocalOnly" { (Invoke-SqlCmd2 @Connect -Query "select d.[name] from sys.databases as d where not exists (select database_name from sys.availability_databases_cluster as adc where adc.[database_name] = d.[name]);").name }
            "@AgOnly" { (Invoke-SqlCmd2 @Connect -Query "select distinct database_name from sys.availability_databases_cluster;").database_name }
            "@All" { @("*") }
            Default {}
        }
    }

    $Database | Where-Object { $_.Substring(0, 1) -eq '-' } | ForEach-Object {
        $db = $_.Substring(1)
        Write-Verbose "Database '$db' will be excluded by user preference. "
        $ExcludeDatabases += $db
    }

    # Non-Existent Databases 
    $Database | Where-Object {
        ($_ -NotIn $AllDatabases) -and
        ($_ -ne "*") -and
        ($_[0] -NotIn @('-', '@'))
    } | ForEach-Object {
        Write-Warning "Input database '$_' does not exist on SqlInstance $($SqlInstance.FullName). The entry will be excluded. "
    }

    if ($Database -Contains "*") {
        $DatabaseCollection = $AllDatabases
    }
    else {
        $DatabaseCollection = $Database | Where-Object { $_ -In $AllDatabases }
    }

    $DatabaseCollection = $DatabaseCollection | Where-Object { $_ -NotIn $ExcludeDatabases }

    $DatabaseCollection
}
