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

echo "Read description in the $PROJECT_ROOT/README.md"

read -p "                                                      Client Name: " CLIENT
read -p "                                                       Jumpbox IP: " JUMPBOX_IP
read -p "                                                       POC Domain: " POC_DOMAIN
read -p "                                                      Root Domain: " ROOT_DOMAIN
read -p "                                                      vCenter URL: " GOVC_URL
read -p "                                                 vCenter username: " GOVC_USERNAME
read -p "                                                 vCenter password: " GOCV_PASSWORD
read -p "          My VMWare User ID (Example: yogendrarampuria@gmail.com): " VMWUSER
read -p "                            My VMware Password (Example: s3cr3t1): " VMWPASS
read -p "               SHARED cluster K8s API IP (Example: 192.168.1.100): " MGMT_API
read -p "Management cluster LB IP Range (Example: 192.168.101-192.168.105): " MGMT_LB_RANGE
read -p "               SHARED cluster K8s API IP (Example: 192.168.1.106): " SHARED_API
read -p "    SHARED cluster LB IP Range (Example: 192.168.107-192.168.110): " SHARED_LB_RANGE
read -p "                  APP cluster K8s API IP (Example: 192.168.1.111): " APPS_API
read -p "       APP cluster LB IP Range (Example: 192.168.112-192.168.115): " APPS_LB_RANGE


cat <<EOF  > $PROJECT_ROOT/.env
CLIENT=$CLIENT
JUMPBOX_IP=$JUMPBOX_IP
POC_DOMAIN=$POC_DOMAIN
ROOT_DOMAIN=$ROOT_DOMAIN
LOCAL_REGISTRY=$JUMPBOX_IP:5000
TKG_CUSTOM_IMAGE_REPOSITORY=$JUMPBOX_IP:5000
TKG_CUSTOM_IMAGE_REPOSITORY_SKIP_TLS_VERIFY=true
GOVC_URL=$GOVC_URL
GOVC_INSECURE=true
GOVC_USERNAME=$GOVC_USERNAME
GOCV_PASSWORD=$GOCV_PASSWORD
VMWUSER=$VMWUSER
VMWPASS=$VMWPASS
MGMT_API=$MGMT_API
MGMT_LB_RANGE=$MGMT_LB_RANGE
SHARED_API=$SHARED_API
SHARED_LB_RANGE=$SHARED_LB_RANGE
APPS_API=$APPS_API
APPS_LB_RANGE=$APPS_LB_RANGE
EOF


