from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
servername = os.uname().nodename
sha_mod = "thanatos_vf_2000.sap.module_utils.ha"

import os
import sys
import psutil

saphostdir = "/usr/sap/hostctrl/exe"
saphostctrl = "saphostctrl"
saphostexec = "saphostexec"
sapcontrol = "sapcontrol"

sys.path.append(saphostdir)

def ha_saphostagent_exist(module):
    status=True
    
    if os.path.isdir(saphostdir):
        if os.path.exists(saphostdir + "/" +saphostctrl) is False:
            module.warn("[%s] %s - %s not present !!!" % (servername, sha_mod, saphostctrl))
            status=False
        if os.path.exists(saphostdir + "/" +saphostexec) is False:
            module.warn("[%s] %s - %s not present !!!" % (servername, sha_mod, saphostexec))
            status=False
        if os.path.exists(saphostdir + "/" +sapcontrol) is False:
            module.warn("[%s] %s - %s not present !!!" % (servername, sha_mod, sapcontrol))
            status=False
    else:
        module.warn("[%s] %s - Directory %s not found!!!" % (servername, sha_mod, saphostdir))
        status=False

    return status

def check_processus_saphostexec():
    for processus in psutil.process_iter():
        try:
            if "/usr/sap/hostctrl/exe/saphostexec" in processus.cmdline():
                return True
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return False

def check_processus_saposcol():
    for processus in psutil.process_iter():
        try:
            if "/usr/sap/hostctrl/exe/saposcol" in processus.cmdline():
                return True
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return False


def get_all_sha_ha(module, app, display):
    ha = list()
    
    if check_processus_saphostexec():
        ha.append({'type': app, 'name': "saphostexec"})

    if check_processus_saposcol():
        ha.append({'type': app, 'name': "saposcol"})

    return ha

get_all_ha = get_all_sha_ha