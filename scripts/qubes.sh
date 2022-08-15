#!/usr/bin/env bash

ANSIBLE_DVM="ansible-dvm"

# Update dom0
sudo qubesctl --show-output state.sls update.qubes-dom0
sudo qubes-dom0-update --clean -y

# Ensure qubes-template-debian-11-minimal is installed
if [ ! -d '/var/lib/qubes/vm-templates/debian-11-minimal' ]; then
  sudo qubes-dom0-update qubes-template-debian-11-minimal
fi

# Download Gas Station and transfer to dom0 via DispVM
qvm-create "$ANSIBLE_DVM" --class DispVM --label=red --property=template=debian-11-minimal-dvm
qvm-run "$ANSIBLE_DVM" curl -sSL https://gitlab.com/megabyte-labs/gas-station/-/archive/master/gas-station-master.tar.gz -o Playbooks.tar.gz
qvm-run --pass-io "$ANSIBLE_DVM" "cat Playbooks.tar.gz" > '/tmp/Playbooks.tar.gz'
# TODO: Install Ansible collections/roles and transport to dom0
tar -xzvf '/tmp/Playbooks.tar.gz' &> /dev/null
rm '/tmp/Playbooks.tar.gz'
qvm-remove --force "$ANSIBLE_DVM"

# Move files to appropriate locations
sudo rm -rf '/etc/ansible'
sudo mv gas-station-master '/etc/ansible'
sudo mkdir -p '/usr/share/ansible/plugins/connection'
sudo ln -s '/etc/ansible/scripts/connection/qubes.py' '/usr/share/ansible/plugins/connection'
sudo mkdir -p '/usr/share/ansible/library'
sudo ln -s '/etc/ansible/scripts/library/qubesos.py' '/usr/share/ansible/library/qubesos.py'
