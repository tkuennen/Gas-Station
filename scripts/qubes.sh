#!/usr/bin/env bash

if [ -d "$HOME/Playbooks" ]; then
  echo "Remove the $HOME/Playbooks directory before continuing" && exit 1
fi

# Download Gas Station and transfer to dom0 via DispVM
qvm-create ansible-playbooks-dvm --class DispVM --label=red --property=template=debian-11-minimal-dvm
qvm-run ansible-dvm curl -sSL https://gitlab.com/megabyte-labs/gas-station/-/archive/master/gas-station-master.tar.gz -o Playbooks.tar.gz
qvm-run --pass-io ansible-dvm "cat Playbooks.tar.gz" > '/tmp/Playbooks.tar.gz'
tar -xzvf '/tmp/Playbooks.tar.gz' &> /dev/null
rm '/tmp/Playbooks.tar.gz'

# Move files to appropriate locations
sudo mv gas-station-master '/etc/ansible'
sudo mkdir -p '/usr/share/ansible/plugins/connection'
sudo ln -s '/etc/ansible/scripts/connection/qubes.py' '/usr/share/ansible/plugins/connection'
sudo mkdir -p '/usr/share/ansible_qubes'
sudo ln -s '/etc/ansible/scripts/library/qubesos.py' '/usr/share/ansible_qubes/qubesos.py'