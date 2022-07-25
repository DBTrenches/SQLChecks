
class DxLogin {
    [string]$Name
    [byte[]]$SecurityId
    [string]$TypeDescription
    [bool]$Enabled = $true
    [string]$DefaultDatabase = 'master'     # s/b custom type
    [string]$DefaultLanguage = 'us_english' # s/b custom type
    [string[]]$ServerRoles                  # s/b custom type
    hidden [string]$ServerRolesAsJson

    DxLogin() {}

    [void]SetServerRolesFromJson() {
        if($this.ServerRolesAsJson){
            $this.ServerRoles = $this.ServerRolesAsJson | ConvertFrom-Json
        }
    }
}

class DxLoginCollection {
    [DxLogin[]]$Logins

    DxLoginCollection() {
        $this.Logins | ForEach-Object {
            $_.SetServerRolesFromJson()
        }
    }

    DxLoginCollection([object[]]$Logins){
        $this.Logins = $Logins

        $this.Logins | ForEach-Object {
            $_.SetServerRolesFromJson()
        }
    }

    [DxLogin[]]GetSysAdmins(){
        $SysAdminCollection = ($this.Logins | Where-Object { $_.ServerRoles -contains 'SysAdmin' })

        return $SysAdminCollection
    }
}

<#
$a = [DxLogin]@{Name='a'; ServerRolesAsJson = '[]'}
$b = [DxLogin]@{Name='b'; ServerRolesAsJson = '["SysAdmin"]'}
$c = [DxLogin]@{Name='c'; ServerRolesAsJson = '["DdlAdmin"]'}
$d = [DxLogin]@{Name='d'; ServerRolesAsJson = '["DdlAdmin","SysAdmin"]'}

$coll = [DxLoginCollection]@{Logins=@($a,$b,$c,$d)}

$d = [DxLogin]@{Name='d'; ServerRoles = @()}
$e = [DxLogin]@{Name='e'; ServerRoles = @('SysAdmin')}
$f = [DxLogin]@{Name='f'; ServerRoles = @('DdlAdmin')}
$g = [DxLogin]@{Name='g'; ServerRoles = @('DdlAdmin','SysAdmin')}

$coll = [DxLoginCollection]@{Logins=@($d,$e,$f,$g)}

$coll.Logins | ft

$coll.GetSysAdmins()
#>
