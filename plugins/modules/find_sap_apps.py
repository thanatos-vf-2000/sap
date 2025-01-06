#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Franck VANHOUCKE (@thanatos-vf-2000) <vanhoucke.franck@free.fr>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: find_sap_apps
short_description: Gathers SAP NetWeaver facts in a host.
version_added: "0.1.0"
description:
    - This data module gathers data from the SAP NetWeaver system on the current instance.
    - This module also indicates the existence of the Diagnostic agent and the SAP HostAgent if present on the server.
attributes:
    check_mode:
      support: none
    diff_mode:
      support: none
options:
    type:
      description:
      - Type of scan to be performed.
      - V(nw) Scan SAP Netweaver.
      - V(da) Scan SAP Diagnostic Agent.
      - V(ha) Scan SAP Host Agent.
      - V(db) Scan Database manage by SAP Host Agent.
      required: false
      choices: [ 'nw', 'da', 'ha', 'db' ]
      default: 'nw'
      type: list
      elements: str
      aliases: [ apps ]
    display:
      description:
      - Information to retrieve.
      - V(info) Display type and name.
      - V(full) Display full information (available in version 1.0.0).
      required: false
      choices: [ 'info', 'full' ]
      default: 'info'
      type: str
      aliases: [ write ]
author:
    - Franck VANHOUCKE (@thanatos-vf-2000) <vanhoucke.franck@free.fr>
'''

EXAMPLES = r'''
- name: Scan only SAP Netweaver
  thanatos_vf_2000.sap.find_sap_apps:
    type: nw
    display: info

- name: Scan ALL and display full
  thanatos_vf_2000.sap.find_sap_apps:
    type: 
      - nw
      - da
      - ha
      - db
    display: full
'''

RETURN = r'''
changed:
    description: State changes.
    returned: always
    type: bool
    sample: true
sap_exists:
    description: SAP present on server.
    type: bool
    elements: True/False
    returned: True When SAP system fact is present
sap:
    description: SAP systems.
    type: list
    elements: dict
    returned: When SAP system is present
'''


from ansible.module_utils.basic import AnsibleModule
from ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.ha import ha_saphostagent_exist, get_all_sha_ha, get_all_ha
from ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.da import get_all_sha_da, get_all_da
from ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.db import get_all_sha_db, get_all_db
from ansible_collections.thanatos_vf_2000.sap.plugins.module_utils.nw import get_all_sha_nw, get_all_nw

import os

def main():
    module = AnsibleModule(
        argument_spec=dict(
            type=dict(type='list', required=False, 
                                  default='nw',
                                  choices=['nw', 'da', 'ha', 'db'],
                                  aliases=['apps']),
            display=dict(type='str', required=False,
                                    default='info',
                                    choices=['info', 'full'],
                                    aliases=['write']),
        ),
        supports_check_mode=True,
    )

    apps = module.params.get('type')
    display = module.params.get('display')

    sap=list()

    result = dict(
        changed=False,
        sap_exists=False,
        sap=dict(),
    )

    if module.check_mode or module._diff:
      if module.check_mode:
        module.warn("please disable check Mode.")
        sap.append({'type': "check", 'name': "true"})
      if module._diff:
        module.warn("please disable diff Mode.")
        sap.append({'type': "diff", 'name': "true"})

      result['sap'] = sap
      module.exit_json(**result)
    
    if os.getuid() != 0:
       module.fail_json(msg='Please used root user.')

    
    for app in apps:
      if ha_saphostagent_exist(module):
        call_function = "get_all_sha_"+app
      else:
         call_function = "get_all_"+app
      if call_function in globals():
          fonction = globals()[call_function]
          sap += fonction(module, app, display)
      else:
          module.fail_json(msg='The function %s does not exist' % (call_function if call_function else 'unknown reason'))

    if sap:
      result['sap_exists'] = True
    result['changed'] = True

    module.exit_json(**result)

if __name__ == '__main__':
    main()