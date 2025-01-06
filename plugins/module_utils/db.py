from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
import re
import sys
from ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.ha import ha_saphostagent_exist

servername = os.uname().nodename
sha_mod = "thanatos_vf_2000.sap.module_utils.db"


saphostdir = "/usr/sap/hostctrl/exe"
saphostctrl = saphostdir + "/saphostctrl"
sapcontrol = saphostdir+ "/sapcontrol"

sys.path.append(saphostdir)



def get_all_sha_db(module, app, display):
    db = list()

    command = [module.get_bin_path('/usr/sap/hostctrl/exe/saphostctrl', required=True)]
    command.extend(['-function', 'ListDatabases'])
    check_instance = module.run_command(command, check_rc=False,expand_user_and_vars=False)
    if check_instance[0] == 0:
        for line in check_instance[1].splitlines():
            if re.search('Instance name:', line):
                data = (line.split(', '))
                db_name = (data[0].split(': '))[-1]
                db_vendor = (data[2].split(': '))[-1]
                db_type = (data[3].split(': '))[-1]
                db.append({'type': app, 'name': db_type, 'sid': db_name, 'type': db_vendor})
    return db

def get_instance_name(database,module):
    instance = ''
    search_instance = r'^Instance name: (.*), Hostname:(.+)'
    search_database = r'Database name: (.*), Status:(.+)'
    command = [module.get_bin_path(saphostctrl, required=True)]
    command.extend(['-function','ListDatabases'])
    check_instance = module.run_command(command, check_rc=False)
    if check_instance[0] != 3:
        for line in check_instance[1].splitlines():
            #Check Instance name
            li = re.search(search_instance, line)
            if li:
                instance = li.group(1)
            ld = re.search(search_database, line)
            if ld:
                if ld.group(1) == database:
                    return instance
            
    return database

def get_hana_sid():
    hana_sid = list()
    if os.path.isdir("/hana/shared"):
        # /hana/shared directory exists
        for sid in os.listdir('/hana/shared'):
            if os.path.isdir("/usr/sap/" + sid) and len(sid) == 3:
                if os.path.isfile("/usr/sap/sapservices"):
                    with open('/usr/sap/sapservices') as f:
                        for index, line in enumerate(f):
                            if sid in line:
                                hana_sid = hana_sid + [sid]
    if hana_sid:
        return hana_sid

def get_hana_nr(app, sids, module, display=False):
    hana_list = list()
    for sid in sids:
        for instance in os.listdir('/usr/sap/' + sid):
            if 'HDB' in instance:
                instance_nr = instance[-2:]
                # check if instance number exists
                command = [module.get_bin_path(sapcontrol, required=True)]
                command.extend(['-nr', instance_nr, '-function', 'GetProcessList'])
                check_instance = module.run_command(command, check_rc=False)
                # sapcontrol returns c(0 - 5) exit codes only c(1) is unavailable
                if check_instance[0] != 1:
                    if ha_saphostagent_exist(module) is True:
                        instance_sid = get_instance_name(sid,module)
                    else:
                        instance_sid = sid
                    hana_list.append({'type': app, 'name': 'HDB', 'sid': instance_sid, 'type': 'hana', 'NR': instance_nr})
                    
    return hana_list
def get_oracle_sid():
    oracle_sid = list()
    instance=""
    if os.path.isfile("/etc/oratab"):
        with open("/etc/oratab",'r') as fo:
            for curline in fo:
                if not curline.startswith("#") and curline != '':
                    instance=curline.split(':')
                    if len(instance) > 2:
                        if (os.path.isdir(instance[1]) or os.path.islink(instance[1])):
                            oracle_sid = oracle_sid + [instance[0]]
    if oracle_sid:
        return oracle_sid

def get_oracle(app, sids, module, display=False):
    oracle_list = list()
    for sid in sids:
        if ha_saphostagent_exist(module) is True:
            instance_sid = get_instance_name(sid,module)
        else:
            instance_sid = sid
        oracle_list.append({'type': app, 'name': 'ORA', 'sid': instance_sid, 'type': 'oracle'})
    return oracle_list

def get_maxdb_sid():
    maxdb_sid = list()
    if os.path.isdir("/sapdb"):
        for sid in os.listdir('/sapdb'):
            if os.path.isdir("/sapdb/" + sid + "/db"):
                maxdb_sid = maxdb_sid + [sid]
    if maxdb_sid:
        return maxdb_sid

def get_maxdb(app, sids, module, display=False):
    maxdb_list = list()
    for sid in sids:
        if ha_saphostagent_exist(module) is True:
            instance_sid = get_instance_name(sid,module)
        else:
            instance_sid = sid
        maxdb_list.append({'type': app, 'name': 'ADA', 'sid': instance_sid, 'type': 'maxdb'})

    return maxdb_list

def get_sybase_sid():
    sybase_sid = list()
    if os.path.isdir("/sybase"):
        for sid in os.listdir('/sybase'):
            if os.path.isfile("/sybase/" + sid + "/SYBASE.sh"):
                sybase_sid = sybase_sid + [sid]
    if sybase_sid:
        return sybase_sid

def get_sybase(app, sids, module, display=False):
    sybase_list = list()
    for sid in sids:
        sybase_list.append({'type': app, 'name': 'SYB', 'sid': sid, 'type': 'syb'})
    return sybase_list

def get_db2_sid():
    db2_sid = list()
    if os.path.isdir("/db2"):
        for sid in os.listdir('/db2'):
            if os.path.isdir("/db2/" + sid ) and len(sid) == 3:
                db2_sid = db2_sid + [sid]
    if db2_sid:
        return db2_sid

def get_db2(app, sids, module, display=False):
    db2_list = list()
    for sid in sids:
        if ha_saphostagent_exist(module) is True:
            instance_sid = get_instance_name(sid,module)
        else:
            instance_sid = sid
        db2_list.append({'type': app, 'name': 'DB6', 'sid': instance_sid, 'type': 'db2'})
        
    return db2_list

def get_mssql_sid():
    mssql_sid = list()
    if os.path.isfile("/opt/mssql/bin/sqlservr"):
        mssql_sid = "yes"
    if mssql_sid:
        return mssql_sid

def get_mssql(app, sids, module, display=False):
    mssql_list = list()
    for sid in sids:
        if ha_saphostagent_exist(module) is True:
            instance_sid = get_instance_name(sid,module)
        else:
            instance_sid = sid
        mssql_list.append({'type': app, 'name': 'MSS', 'sid': instance_sid, 'type': 'mssql'})
    return mssql_list

def get_all_db(module, app, display):
    db = list()

    hana_sid = get_hana_sid()
    if hana_sid:
        db = db + get_hana_nr(app, hana_sid, module, display)

    oracle_sid = get_oracle_sid()
    if oracle_sid:
        db = db + get_oracle(app, oracle_sid, module, display)
    
    maxdb_sid = get_maxdb_sid()
    if maxdb_sid:
        db = db + get_maxdb(app, maxdb_sid, module, display)


    sybase_sid = get_sybase_sid()
    if sybase_sid:
        db = db + get_sybase(app, sybase_sid, module, display)

    db2_sid = get_db2_sid()
    if db2_sid:
        db = db + get_db2(app, db2_sid, module, display)

    mssql_sid = get_mssql_sid()
    if mssql_sid:
        db = db + get_mssql(app, mssql_sid, module, display)

    return db