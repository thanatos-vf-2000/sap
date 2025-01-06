# Copyright: (c) 2025, Franck VANHOUCKE (@thanatos-vf-2000) <vanhoucke.franck@free.fr>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$DebugPreference = "Continue"
$VerbosePreference = "Continue"

$sha_mod = "thanatos_vf_2000.sap.module_utils.WinDA"


Function Get-SAPDaaDid {
    $GetService = Get-Service |Where-Object { $_.Name -like "SAP*_*" -and $_.Name -like "SAPDAA*" }
    if ( ($GetService | Measure-Object).Count -gt 0 ) {
        (Get-Service |Where-Object { $_.Name -like "SAP*_*" -and $_.Name -like "SAPDAA*" }).Name
    } else {
        $null
    }
}

Function Get-daanr {
    param($sids, $display=$false)

    $global:ansible_facts = foreach ($sid in $sids) {
        $sid.replace('SAP','') | % { $service = @($_ -split '_'); }
        (Get-CimInstance Win32_Service -Filter "Name='$($sid)'").PathName | % { $sap_patch = @($_ -split '\\'); }
        $pos = (0..($sap_patch.Count-1)) | Where-Object {$sap_patch[$_] -eq $service[0]}
        @{
            SID = $service[0];
            NR = $service[1]
            TYPE = "SMD"
        }
    }    
}
# this line must stay at the bottom to ensure all defined module parts are exported
Export-ModuleMember -Alias * -Function * -Cmdlet *