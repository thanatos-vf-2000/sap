from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
servername = os.uname().nodename
sha_mod = "thanatos_vf_2000.sap.module_utils.nw"

import re

def get_instance_type(raw_type):
    sap=list()
    type=""
    hasABAP=0
    hasJava=0
    hasSpecial=0
    start=99
    stop=99
    sapccm4x=0
    startsrv=0

    raw_type = raw_type + "Z"
    
    if raw_type[0] == "D" and raw_type[1] == "V":
        # ABAP Central Instance
        type = "CI"
        hasABAP=1
        sapccm4x=1
        start=4
        stop=10
        startsrv=1
    elif raw_type[0] == "D":
        # ABAP Dialog Instance
        type = "PAS"
        hasABAP=1
        sapccm4x=1
        start=6
        stop=9
        startsrv=2
    elif raw_type[0] == "A" and raw_type[1] == "S":
        # ABAP SCS Instance
        type = "ASCS"
        hasSpecial=1
        sapccm4x=1
        start=3
        stop=11
        startsrv=4
    elif raw_type[0] == "S" and raw_type[1] == "C":
        # Java SCS Instance
        type = "SCS"
        hasSpecial=1
        sapccm4x=1
        start=2
        stop=8
        startsrv=3
    elif raw_type[0] == "J" and raw_type[1] == "M":
        # JMS Instance
        type = "JMS"
        hasJava=1
        sapccm4x=1
        start=8
        stop=6
        startsrv=9
    elif raw_type[0] == "J" and raw_type[1] == "C":
        # Java Central Instance
        type = "Java"
        hasJava=1
        sapccm4x=1
        start=5
        stop=7
        startsrv=8
    elif raw_type[0] == "J":
        # Java Dialog Instance
        type = "Java"
        hasJava=1
        sapccm4x=1
        start=7
        stop=5
        startsrv=7
    elif raw_type[0] == "T":
        # TREX Instance
        type = "TREX"
        hasSpecial=1
        sapccm4x=1
        start=11
        stop=3
    elif raw_type[0] == "E":
        # Enque Replication Service Instance
        type = "ERS"
        hasSpecial=1
        sapccm4x=1
        start=1
        stop=12
        startsrv=5
    elif raw_type[0] == "S" and raw_type[1] == "M":
        # Diagnostics Agent Instance
        type = "SMDA"
        hasSpecial=1
        sapccm4x=1
        start=12
        stop=1
        startsrv=6
    elif raw_type[0] == "W":
        # Web Services Instance
        type = "Web"
        hasSpecial=1
        sapccm4x=1
        start=9
        stop=5
        startsrv=11
    elif raw_type[0] == "G":
        # Gateway Instance
        type = "Gateway"
        hasSpecial=1
        sapccm4x=1
        start=13
        stop=2
    elif raw_type[0] == "V":
        # Virus Scan Server Instance
        type = "VirusScan"
        hasSpecial=1
        sapccm4x=1
        start=10
        stop=4
        startsrv=10
    else:
        # Unknown instance type
        type = "XXX"
        start=4
        stop=11

    sap.append( {
            'type': type,
            'hasABAP': hasABAP,
            'hasJava': hasJava,
            'hasSpecial': hasSpecial,
            'start': start,
            'stop': stop,
            'sapccm4x': sapccm4x,
            'startsrv': startsrv
        })
    return sap

def get_all_nw(module, app, display):
    nw = list()

    nw_sid = list()
    if os.path.isdir("/sapmnt"):
        for sid in os.listdir('/sapmnt'):
            if os.path.isdir("/usr/sap/" + sid) and len(sid) == 3 and sid != 'DAA' and os.path.isdir("/usr/sap/" + sid + "/SYS") :
                nw_sid = nw_sid + [sid]

        for sid in nw_sid:
            for instance in os.listdir('/usr/sap/' + sid):
                instance_nr = instance[-2:]
                if instance_nr.isdigit():
                    type = instance[:-2]
                    nw_instance = get_instance_type(type)
                    nw.append({'type': app, 'name': nw_instance[0]['type'], 'sid': sid, 'nr': instance_nr})

    return nw

def get_all_sha_nw(module, app, display):
    nw = list()

    nw_sid = list()
    if os.path.isdir("/sapmnt"):
        for sid in os.listdir('/sapmnt'):
            if os.path.isdir("/usr/sap/" + sid) and len(sid) == 3 and sid != 'DAA' and os.path.isdir("/usr/sap/" + sid + "/SYS") :
                nw_sid = nw_sid + [sid]

        for sid in nw_sid:
            for instance in os.listdir('/usr/sap/' + sid):
                instance_nr = instance[-2:]
                command = [module.get_bin_path('/usr/sap/hostctrl/exe/sapcontrol', required=True)]
                if instance_nr.isdigit():
                    command.extend(['-nr', instance_nr, '-function', 'GetInstanceProperties'])
                    check_instance = module.run_command(command, check_rc=False,expand_user_and_vars=False)
                    if check_instance[0] != 1:
                        # Get information if sapcontrol
                        for line in check_instance[1].splitlines():
                            if re.search('INSTANCE_NAME', line):
                                # convert to list and extract last
                                type_raw = (line.strip('][').split(', '))[-1]
                                # split instance number
                                type = type_raw[:-2]
                                nw_instance = get_instance_type(type)
                                nw.append({'type': app, 'name': nw_instance[0]['type'], 'sid': sid, 'nr': instance_nr})

    return nw