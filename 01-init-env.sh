#!/usr/bin/env bash
SCRIPT_ROOT=$( cd `dirname $0`; pwd)
echo "Read description in the $SCRIPT_ROOT/README.md"

read -p " Enter value for client name [CLIENT]: " CLIENT
read -p " Enter value for jumpbox ip [JUMPBOX_IP]: " JUMPBOX_IP
read -p " Enter value for poc domain [POC_DOMAIN]: " POC_DOMAIN
read -p " Enter value for root domain [ROOT_DOMAIN]: " ROOT_DOMAIN
read -p " Enter value for vcenter URL [GOVC_URL]: " GOVC_URL
read -p " Enter value for vcenter username [GOVC_USERNAME]: " GOVC_USERNAME
read -p " Enter value for vcenter password [GOCV_PASSWORD]: " GOCV_PASSWORD

cat <<EOF  > $SCRIPT_ROOT/.env
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


