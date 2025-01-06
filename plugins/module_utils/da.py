from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
servername = os.uname().nodename
sha_mod = "thanatos_vf_2000.sap.module_utils.da"

import re

def get_all_sha_da(module, app, display):
    da = list()

    daa_sid = list()
    if os.path.isdir("/usr/sap"):
        for sid in os.listdir('/usr/sap'):
            if not os.path.isdir("/sapmnt/" + sid) and not os.path.isdir("/hana/shared/" + sid) and not os.path.isdir("/usr/sap/" + sid + "/SYS/global/trex") and os.path.isdir("/usr/sap/" + sid+ "/SYS"):
                if len(sid) == 3 and sid != 'tmp' and sid == 'DAA':
                    daa_sid = daa_sid + [sid]
        for sid in daa_sid:
          for instance in os.listdir('/usr/sap/' + sid):
            instance_nr = instance[-2:]
            command = [module.get_bin_path('/usr/sap/hostctrl/exe/sapcontrol', required=True)]
            if instance_nr.isdigit():
                command.extend(['-nr', instance_nr, '-function', 'GetInstanceProperties'])
                check_instance = module.run_command(command, check_rc=False)
                if check_instance[0] != 1:
                    for line in check_instance[1].splitlines():
                        if re.search('INSTANCE_NAME', line):
                            da.append({'type': app, 'name': "SMD", 'sid': sid, 'nr': instance_nr})
                            
    return da

def get_all_da(module, app, display):
    da = list()

    daa_sid = list()
    if os.path.isdir("/usr/sap"):
        for sid in os.listdir('/usr/sap'):
            if not os.path.isdir("/sapmnt/" + sid) and not os.path.isdir("/hana/shared/" + sid) and not os.path.isdir("/usr/sap/" + sid + "/SYS/global/trex") and os.path.isdir("/usr/sap/" + sid+ "/SYS"):
                if len(sid) == 3 and sid != 'tmp' and sid == 'DAA':
                    daa_sid = daa_sid + [sid]
        for sid in daa_sid:
          for instance in os.listdir('/usr/sap/' + sid):
            instance_nr = instance[-2:]
            da.append({'type': app, 'name': "SMD", 'sid': sid, 'nr': instance_nr})
                            
    return da