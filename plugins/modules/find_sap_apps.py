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
      - V(full) Display full information..
      required: false
      choices: [ 'info', 'full' ]
      default: 'present'
      type: str
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
'''


from ansible.module_utils.basic import AnsibleModule