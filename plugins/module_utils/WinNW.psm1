# Copyright: (c) 2025, Franck VANHOUCKE (@thanatos-vf-2000) <vanhoucke.franck@free.fr>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$DebugPreference = "Continue"
$VerbosePreference = "Continue"

$sha_mod = "thanatos_vf_2000.sap.module_utils.WinNW"

Function Get-SAPNwSid {
    $GetService = Get-Service |Where-Object { $_.Name -like "SAP???_??" -and $_.Name -notlike "SAPDAA*" }
    if ( ($GetService | Measure-Object).Count -gt 0 ) {
        (Get-Service |Where-Object { $_.Name -like "SAP???_??" -and $_.Name -notlike "SAPDAA*" }).Name
    } else {
        $null
    }
}

Function ParseGetProcessList {
    param([object[]]$Lines)

    $skip = 5
    $tab = @()

    $Lines | Select-Object -Skip $skip | ForEach-Object {
        $columns = ($_ -split ',').Trim() | Where-Object {$_ }
        $tab += [pscustomobject]@{
            Name = $($columns[0])
            Description = $($columns[1])
            Status = $($columns[2]).ToLower()
            TxtStatus = $($columns[3]).ToLower()
        }
    }
    Return $tab
}

Function Get-SapInstanceType{
    param($type)

    $type2=""
    $hasABAP=0
    $hasJava=0
    $hasSpecial=0
    $start=99
    $stop=99
    $sapccm4x=0
    $startsrv=0

    if ($type[0] -eq "D" -and $type[1] -eq "V") {
        # ABAP Central Instance
        $type2 = "CI"
        $hasABAP=1
        $sapccm4x=1
        $start=4
        $stop=10
        $startsrv=1
    } elseif ($type[0] -eq "D") {
        # ABAP Dialog Instance
        $type2 = "PAS"
        $hasABAP=1
        $sapccm4x=1
        $start=6
        $stop=9
        $startsrv=2
    } elseif ($type[0] -eq "A" -and $type[1] -eq "S") {
        # ABAP SCS Instance
        $type2 = "ASCS"
        $hasSpecial=1
        $sapccm4x=1
        $start=3
        $stop=11
        $startsrv=4
    } elseif ($type[0] -eq "S" -and $type[1] -eq "C") {
        # Java SCS Instance
        $type2 = "SCS"
        $hasSpecial=1
        $sapccm4x=1
        $start=2
        $stop=8
        $startsrv=3
    } elseif ($type[0] -eq "J" -and $type[1] -eq "M") {
        # JMS Instance
        $type2 = "JMS"
        $hasJava=1
        $sapccm4x=1
        $start=8
        $stop=6
        $startsrv=9
    } elseif ($type[0] -eq "J" -and $type[1] -eq "C") {
        # Java Central Instance
        $type2 = "Java"
        $hasJava=1
        $sapccm4x=1
        $start=5
        $stop=7
        $startsrv=8
    } elseif ($type[0] -eq "J") {
        # Java Dialog Instance
        $type2 = "Java"
        $hasJava=1
        $sapccm4x=1
        $start=7
        $stop=5
        $startsrv=7
    } elseif ($type[0] -eq "T") {
        # TREX Instance
        $type2 = "TREX"
        $hasSpecial=1
        $sapccm4x=1
        $start=11
        $stop=3
    } elseif ($type[0] -eq "E") {
        # Enque Replication Service Instance
        $type2 = "ERS"
        $hasSpecial=1
        $sapccm4x=1
        $start=1
        $stop=12
        $startsrv=5
    } elseif ($type[0] -eq "S" -and $type[1] -eq "M") {
        # Diagnostics Agent Instance
        $type2 = "SMDA"
        $hasSpecial=1
        $sapccm4x=1
        $start=12
        $stop=1
        $startsrv=6
    } elseif ($type[0] -eq "W") {
        # Web Services Instance
        $type2 = "Web"
        $hasSpecial=1
        $sapccm4x=1
        $start=9
        $stop=5
        $startsrv=11
    } elseif ($type[0] -eq "G") {
        # Gateway Instance
        $type2 = "Gateway"
        $hasSpecial=1
        $sapccm4x=1
        $start=13
        $stop=2
    } elseif ($type[0] -eq "V") {
        # Virus Scan Server Instance
        $type2 = "VirusScan"
        $hasSpecial=1
        $sapccm4x=1
        $start=10
        $stop=4
        $startsrv=10
    } else {
        # Unknown instance type
        $type2 = "XXX"
        $start=4
        $stop=11
    }
        

    return @{
        type2= $type2;
        hasABAP= $hasABAP;
        hasJava= $hasJava;
        hasSpecial= $hasSpecial;
        start= $start;
        stop= $stop;
        sapccm4x= $sapccm4x;
        startsrv= $startsrv;
    }

}

Function Get-SAPNwStatus {
    param($sids)

    $apps =  @()
    $srv = @()

    $apps = foreach ($sid in $sids) {
        $sid.replace('SAP','') | % { $service = @($_ -split '_'); }
        (Get-CimInstance Win32_Service -Filter "Name='$($sid)'").PathName | % { $sap_patch = @($_ -split '\\'); }
        $pos = (0..($sap_patch.Count-1)) | where {$sap_patch[$_] -eq $service[0]}
        $type=$sap_patch[$pos[0]+1]
        $CmdSAPStatus = -join("sapcontrol.exe -nr ",$service[1]," -function GetProcessList")
        $SAPStatus = Invoke-Expression $CmdSAPStatus
        $SAPSystems = (ParseGetProcessList($SAPStatus) |Select-Object Name, Status)
        foreach ($SAPSystem in $SAPSystems) {
            $srv += @{
                name = $SAPSystem.Name;
                status = $SAPSystem.Status.ToLower();
            }
        }
        @{
            "apps" = "SAP NetWeaver"
            "type" = (Get-SapInstanceType -type $type).type2
            "sid" = $service[0]
            "nr" = $service[1]
            "services" = $srv
        }
        if ($srv.Count -ne 0 ) {
            $srv = @($srv | Where-Object { $_ -ne $False })
        }
    }

    return $apps
}

# this line must stay at the bottom to ensure all defined module parts are exported
Export-ModuleMember -Alias * -Function * -Cmdlet *