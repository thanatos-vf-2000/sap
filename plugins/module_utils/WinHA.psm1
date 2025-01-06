# Copyright: (c) 2025, Franck VANHOUCKE (@thanatos-vf-2000) <vanhoucke.franck@free.fr>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$DebugPreference = "Continue"
$VerbosePreference = "Continue"

$SAPHOSTDIR="C:\Program Files\SAP\hostctrl\exe"
$SAPHOSTCTRL="saphostctrl.exe"
$SAPHOSTEXEC="saphostexec.exe"
$SAPCONTROL="sapcontrol.exe"

$env:PATH += ";$SAPHOSTDIR"


$sha_mod = "thanatos_vf_2000.sap.module_utils.WinHA"


Function Get-SAPHostAgentTest {
    param($result=$true)

    $status = $true

    if (Test-Path -Path "$SAPHOSTDIR" ) {
        if (-Not(Test-Path -Path "$SAPHOSTDIR\$SAPHOSTCTRL" -PathType Leaf)) {
            Add-Warning -obj $warnings -message "$sha_mod - $SAPHOSTCTRL not present !!!"
            $status = $false
        }
        if (-Not(Test-Path -Path "$SAPHOSTDIR\$SAPHOSTEXEC" -PathType Leaf)) {
            Add-Warning -obj $warnings -message "$sha_mod - $SAPHOSTEXEC not present !!!"
            $status = $false
        }
        if (-Not(Test-Path -Path "$SAPHOSTDIR\$SAPCONTROL" -PathType Leaf)) {
            Add-Warning -obj $warnings -message "$sha_mod - $SAPCONTROL not present !!!"
            $status = $false
        }
    } Else {
        Add-Warning -obj $warnings -message "$sha_mod - Directory $SAPHOSTDIR not found!!!"
        $status = $false
    }
    

    return $status
}


Function Get-SAPHostexecStatus() {
    $app = @{
        "apps" = "SAP hostctrl"
        "type" = "hostctrl"
        "sid" = ""
        "nr" = ""
        "services" = @()
    }

    $services = @("SAPHostControl", "SAPHostExec")

    $srv = foreach ($service in $services) {
        Get-Service |Where-Object { $_.Name -like "$service"} | ForEach-Object {
            @{
                name = $_.Name;
                status = $_.Status.ToString().ToLower();
            }
        }
    }

    $app['services'] = $srv
    return $app
    
}

# this line must stay at the bottom to ensure all defined module parts are exported
Export-ModuleMember -Alias * -Function * -Cmdlet *