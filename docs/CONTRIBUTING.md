# Contributing to the Ansible thanatos_vf_2000.sap Collection

Thanks for your interest in thanatos_vf_2000.sap. 

- [Contributing to the Ansible thanatos_vf_2000.sap Collection](#contributing-to-the-ansible-thanatos-vf-2000sap-collection)
  * [Prerequisites](#prerequisites)
  * [Set up a development environment](#set-up-a-development-environment)
    + [Verification](#verification)
    + [Useful links](#useful-links)
  * [Testing](#testing)
    + [Unit tests](#unit-tests)
    + [Integration tests](#integration-tests)
  * [Releasing](#releasing)
<!-- Table of contents generated with markdown-toc
http://ecotrust-canada.github.io/markdown-toc/ -->

## Prerequisites

Before getting started, the following tools need to be installed:

1. [Git][get-git] to manage source code


[get-git]: https://git-scm.com/downloads

## Set up a development environment

### Verification

### Useful links

## Testing

### Unit tests

### Integration tests


## Releasing

From a clean instance of main, perform the following actions to release a new version
of this plugin:

- Update the version number in [`galaxy.yml`](galaxy.yml) and [`CHANGELOG.md`](CHANGELOG.md)
    - Verify that all changes for this version in `CHANGELOG.md` are clear and accurate,
      and are followed by a link to their respective issue
    - Create a PR with these changes

- Create an annotated tag with the new version, formatted as `v##.##.##`
    - This will kick off an automated script which publish the release to
      [Ansible Galaxy](https://galaxy.ansible.com/thanatos_vf_2000/sap)

- Create the release on GitHub for that tag
    - Build the release package with `ansible-galaxy collection build ...`
    - Attach package to Github Release

