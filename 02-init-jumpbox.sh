#!/usr/bin/env bash

SCRIPT_ROOT=$( cd `dirname $0`; pwd)
source $SCRIPT_ROOT/.env

curl -sSL https://raw.githubusercontent.com/yogendra/dotfiles/master/scripts/jumpbox-init.sh | bash -s common k8s vsphere


echo Patch docker daemon
sudo cat > /etc/docker/daemon.json << EOF
{
"insecure-registries": ["${JUMPBOX_IP}:5000", "localhost:5000"]
}
EOF
sudo systemctl restart docker

echo Allow Kind to Docker communication iptables

sudo iptables -A INPUT -i docker0 -j ACCEPT

sudo apt-get install -qqy iptables-persistent

sudo systemctl start netfilter-persistent

