#!powershell

# Copyright: (c) 2025, Franck VANHOUCKE (@thanatos-vf-2000) <vanhoucke.franck@free.fr>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType


#Requires -Module ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.WinHA
#AnsibleRequires -PowerShell ..module_utils.WinHA
#Requires -Module ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.WinDA
#AnsibleRequires -PowerShell ..module_utils.WinDA
#Requires -Module ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.WinNW
#AnsibleRequires -PowerShell ..module_utils.WinNW
#Requires -Module ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.WinDB
#AnsibleRequires -PowerShell ..module_utils.WinDB


# Create a new result object
$result = @{
    changed = $false
    ansible_facts = @{
        apps_detect =  @()
    }
}

# Elevating Priviledge
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))`
    { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# SAP Host Agent
if ( Get-SAPHostAgentTest ) {
    $result.ansible_facts.apps_detect += Get-SAPHostexecStatus
}

# SAP Diagnostoc Agent
$daa_sid = Get-SAPDaaDid
if ($daa_sid -ne $null) {
    $result.ansible_facts.apps_detect += Get-SAPDAAStatus -sids $daa_sid

}

# SAP Netweaver
$nw_sid = Get-SAPNwSid
if ($nw_sid -ne $null) {
    $result.ansible_facts.apps_detect += Get-SAPNwStatus -sids $nw_sid
}


# DB
$mssql_sid = Get-DBAllMsSqlSid
if ($mssql_sid -ne $null) {
    $result.ansible_facts.apps_detect += Get-DBStatus -sids $mssql_sid -type "mssql"
}

$maxdb_sid = Get-DBAllMaxDbSid
if ($maxdb_sid -ne $null) {
    $result.ansible_facts.apps_detect += Get-DBStatus -sids $maxdb_sid -type "maxdb"
}

$sybase_sid = Get-DBAllSybaseSid
if ($sybase_sid -ne $null) {
    $result.ansible_facts.apps_detect += Get-DBStatus -sids $sybase_sid -type "sybase"
}

$oracle_sid = Get-DBAllOracleSid
if ($oracle_sid -ne $null) {
    $result.ansible_facts.apps_detect += Get-DBStatus -sids $oracle_sid -type "oracle"
}

$db2_sid = Get-DBAllDb2Sid
if ($db2_sid -ne $null) {
    $result.ansible_facts.apps_detect += Get-DBStatus -sids $db2_sid -type "db2"
}
Exit-Json -obj $result