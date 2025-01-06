# Copyright: (c) 2025, Franck VANHOUCKE (@thanatos-vf-2000) <vanhoucke.franck@free.fr>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$DebugPreference = "Continue"
$VerbosePreference = "Continue"

$sha_mod = "thanatos_vf_2000.sap.module_utils.WinDB"


$AutomationPath = "C:\oxya_automation"
$SAPHOSTDIR="C:\Program Files\SAP\hostctrl\exe"
$SAPHOSTCTRL="saphostctrl.exe"
$SAPHOSTEXEC="saphostexec.exe"

$env:PATH += ";$SAPHOSTDIR"

Function  Get-InstanceName {
    param($Database)
    try {
        $CmdDBStatus = -join($SAPHOSTCTRL," -function ListDatabases")
        $DBList = Invoke-Expression $CmdDBStatus
        $DB = (ParseGetDBList($DBList) |Where-Object {$_.SID -eq "$Database"})
        if ( ($DB | Measure-Object).Count -gt 0) {
            return $DB.instance
        } Else {
            return $Database
        }
    } catch {
        return $Database
    }

}

Function Get-DBAllMsSqlSid {
    $GetService = Get-Service |Where-Object { $_.Name -like "MSSQLSERVER" -or $_.DisplayName -like "SQL Server (*" }
    if ( ($GetService | Measure-Object).Count -gt 0 ) {
            (Get-Service |Where-Object { $_.Name -like "MSSQLSERVER" -or $_.DisplayName -like "SQL Server (*"}).Name
    } else {
        $null
    }
}

Function Get-DBMsSqlnr {
    param($sids, $all_info=$false)
    $DBSaphostagent = Check-SAPHostExec

    $global:ansible_facts += foreach ($sid in $sids) {
        if ($DBSaphostagent) {
            $InstanceSid = Get-InstanceName($sid)
        } else {
            $InstanceSid = ""
        }
        if ( -not $all_info) {
            @{
                SID = $sid;
                TYPE = 'mssql'
                saphostagent = $DBSaphostagent
                instance = $InstanceSid
            }
        } else {
            @{
                SID = $sid -replace "MSSQL\$", "";
                TYPE = 'mssql'
                saphostagent = $DBSaphostagent
                USER = Get-DbUser -Service $sid
                order_start = 2
                order_stop = 98
                EXE = Get-DbExe -Service $sid
                AWX_TOOLS = "db"
                instance = $InstanceSid
            }
        }
    }    
}

Function Get-DBAllMaxDbSid {
    $GetService = Get-Service |Where-Object { $_.Name -like "SAP DBTech-*" -or $_.Name -like "MAXDB:*"}
    if ( ($GetService | Measure-Object).Count -gt 0 ) {
        (Get-Service |Where-Object { $_.Name -like "SAP DBTech-*" -or $_.Name -like "MAXDB:*"}).Name
    } else {
        $null
    }
}

Function Get-DBMaxDbnr {
    param($sids, $all_info=$false)

    $global:ansible_facts += foreach ($sid in $sids) {
        $db=""
        if ($sid.Contains("SAP DBTech-")) {
            $db = $sid.replace('SAP DBTech-','')
        }
		if ($sid.Contains("MAXDB:")) {
            $db= $sid.replace('MAXDB: ','')
        }
        $nbc = ($db | Measure-Object -Character).Characters
        if ($nbc -eq 3) {
            $DBSaphostagent = Check-SAPHostExec
            if ($DBSaphostagent) {
                $InstanceSid = Get-InstanceName($db)
            } else {
                $InstanceSid = ""
            }
            if ( -not $all_info) {
                @{
                    SID = $db;
                    TYPE = 'maxdb'
                    saphostagent = $DBSaphostagent
                    instance = $InstanceSid
                }
            } else {
                @{
                    SID = $db;
                    TYPE = 'maxdb'
                    saphostagent = $DBSaphostagent
                    USER = Get-DbUser -Service $sid
                    order_start = 2
                    order_stop = 98
                    EXE = Get-DbExe -Service $sid
                    AWX_TOOLS = "db"
                    instance = $InstanceSid
                }
            }
        }
    }    
}

Function Get-DBMaxDbXServer {
    param($sids )    
    $global:ansible_facts += Get-Service | Where-Object { $_.Name -like "XServer*" } |ForEach-Object {
        @{
            SID = $_.Name;
            TYPE = 'x_server'
            saphostagent = Check-SAPHostExec
            USER = Get-DbUser -Service $_.Name
            order_start = 1
            order_stop = 99
            EXE = Get-DbExe -Service $_.Name
            AWX_TOOLS = "db"
            instance = ""
        }
    }
}

Function Get-DBAllSybaseSid {
    $GetService = Get-Service |Where-Object { $_.Name -like "Sybase SQLServer*" }
    if ( ($GetService | Measure-Object).Count -gt 0 ) {
        (Get-Service |Where-Object { $_.Name -like "Sybase SQLServer*" }).Name
    } else {
        $null
    }
}

Function Get-DBSybasenr {
    param($sids, $all_info=$false)

    $global:ansible_facts += foreach ($sid in $sids) {
		$sid.replace('Sybase ','') | % { $service = @($_ -split '_'); }
        $DBSaphostagent = Check-SAPHostExec
        if ($DBSaphostagent) {
            $InstanceSid = Get-InstanceName($service[1])
        } else {
            $InstanceSid = ""
        }
        if ( -not $all_info) {
            @{
                SID = $service[1];
                TYPE = 'sybase'
                saphostagent = $DBSaphostagent
                instance = $InstanceSid
            }
        } else {
            @{
                SID = $service[1];
                TYPE = 'sybase'
                saphostagent = $DBSaphostagent
                USER = Get-DbUser -Service $sid
                order_start = 2
                order_stop = 98
                EXE = Get-DbExe -Service $sid
                AWX_TOOLS = "db"
                instance = $InstanceSid
            }
        }
    }    
}

Function Get-DBAllOracleSid {
    $GetService = Get-Service |Where-Object { $_.Name -like "OracleService*" }
    if ( ($GetService | Measure-Object).Count -gt 0 ) {
        (Get-Service |Where-Object { $_.Name -like "OracleService*" }).Name
    } else {
        $null
    }
}

Function Get-DBOraclenr {
    param($sids, $all_info=$false)

    $global:ansible_facts += foreach ($sid in $sids) {
		$db = $sid.replace('OracleService','')
        $DBSaphostagent = Check-SAPHostExec
        if ( -not $all_info) {
            @{
                SID = $db;
                TYPE = 'oracle'
                saphostagent = $DBSaphostagent
                instance = ""
            }
        } else {
            @{
                SID = $db;
                TYPE = 'oracle'
                saphostagent = $DBSaphostagent
                USER = Get-DbUser -Service $sid
                order_start = 2
                order_stop = 98
                EXE = Get-DbExe -Service $sid
                AWX_TOOLS = "db"
                instance = ""
            }
        }
    }    
}

Function Get-DBOracleListener {
    $GetService = (Get-Service |Where-Object { $_.Name -like "Oracle*Listener*" }).Name
    if ( ($GetService | Measure-Object).Count -gt 0 ) {
        $global:ansible_facts += foreach ($Listener in $GetService) {
            @{
                SID = $Listener;
                TYPE = 'listener'
                saphostagent = Check-SAPHostExec
                USER = Get-DbUser -Service $Listener
                order_start = 1
                order_stop = 99
                EXE = Get-DbExe -Service $Listener
                AWX_TOOLS = "db"
                instance = ""
            }
        }
    } else {
        $null
    }
}

Function Get-DBAllDb2Sid {
    $GetService = Get-Service |Where-Object { $_.Name -like "DB2 - SAPDB2*" }
    if ( ($GetService | Measure-Object).Count -gt 0 ) {
        (Get-Service |Where-Object { $_.Name -like "DB2 - SAPDB2*" }).Name
    } else {
        $null
    }
}

Function Get-DBDb2nr {
    param($sids, $all_info=$false)

    $global:ansible_facts += foreach ($sid in $sids) {
		$db = $sid.replace('DB2 - SAPDB2','')
        $DBSaphostagent = Check-SAPHostExec
        if ($DBSaphostagent) {
            $InstanceSid = Get-InstanceName($db)
        } else {
            $InstanceSid = ""
        }
        if ( -not $all_info) {
            @{
                SID = $db;
                TYPE = 'db2'
                saphostagent = $DBSaphostagent
                instance = $InstanceSid
            }
        } else {
            @{
                SID = $db;
                TYPE = 'db2'
                saphostagent = $DBSaphostagent
                USER = Get-DbUser -Service $sid
                order_start = 2
                order_stop = 98
                EXE = Get-DbExe -Service $sid
                AWX_TOOLS = "db"
                instance = $InstanceSid
            }
        }
    }    
}

Function ParseGetDBList() {
    param([object[]]$Lines)

    $tab = @()

    $Lines | Select-Object | ForEach-Object {
        $columns = ($_ -split ',').Trim() | Where-Object {$_ }
        if ($columns[0] -match 'Instance name:*') {
            $ldbtype  = $($columns[2]).split(':').Trim()
            $instance = $($columns[0]).split(':').Trim()
        }
		if ($columns[0] -match 'Database name:*') {
			$sidd=$($columns[0]).split(':').Trim()
			$status=($columns[1]).split(':').Trim()
			$tab += [pscustomobject]@{
				SID = $($sidd[1])
				Status = $($status[1])
                Type = $($ldbtype[1])
                Instance = $($instance[1])
			}
		}
    }
    Return $tab
}

function ParseGetDBSubServiceList() {
    param([object[]]$Lines)

    $tab = @()

    $Lines | Select-Object -skip 1| ForEach-Object {
        $columns = ($_ -split ',').Trim() | Where-Object {$_ }
        $SubService=((($columns[0]).split(':').Trim())[1]).split('(')[0].Trim()
        $status=((($columns[1]).split(':').Trim())[1]).split('(')[0].Trim()
        $tab += [pscustomobject]@{
            SubService = $($SubService)
            Status = $($status)
        }

    }
    Return $tab
}

# this line must stay at the bottom to ensure all defined module parts are exported
Export-ModuleMember -Alias * -Function * -Cmdlet *