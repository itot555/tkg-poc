#!/usr/bin/env bash
# Copyright 2020 The TKG Contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPT_ROOT=$( cd `dirname $0`; pwd)
PROJECT_ROOT=${PROJECT_ROOT:-$(cd $SCRIPT_ROOT/..; pwd)}
source $PROJECT_ROOT/.env


curl -sSL https://raw.githubusercontent.com/yogendra/dotfiles/master/scripts/jumpbox-init.sh | bash -s common k8s vsphere


echo Patch docker daemon
sudo cat > /etc/docker/daemon.json << EOF
{
"insecure-registries": [ "${LOCAL_REGISTRY}", "localhost:5000", "127.0.0.1:5000"]
}
EOF
sudo systemctl restart docker

echo Allow Kind to Docker communication iptables

sudo iptables -A INPUT -i docker0 -j ACCEPT

sudo apt-get install -qqy iptables-persistent

sudo systemctl start netfilter-persistent

mkcert -init

mkdir -p $PROJECT_ROOT/certs

cp $(mkcert -CAROOT)/rootCA.pem certs/ca.crt

curl -sSL https://github.com/goharbor/harbor/releases/download/v2.1.0/harbor-offline-installer-v2.1.0.tgz -o packages/harbor-offline-installer-v2.1.0.tgz
