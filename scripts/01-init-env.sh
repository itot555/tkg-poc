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

read -p " Enter value for client name [CLIENT]: " CLIENT
read -p " Enter value for jumpbox ip [JUMPBOX_IP]: " JUMPBOX_IP
read -p " Enter value for poc domain [POC_DOMAIN]: " POC_DOMAIN
read -p " Enter value for root domain [ROOT_DOMAIN]: " ROOT_DOMAIN
read -p " Enter value for vcenter URL [GOVC_URL]: " GOVC_URL
read -p " Enter value for vcenter username [GOVC_USERNAME]: " GOVC_USERNAME
read -p " Enter value for vcenter password [GOCV_PASSWORD]: " GOCV_PASSWORD

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
EOF


