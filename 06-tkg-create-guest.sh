#!/usr/bin/env bash

SCRIPT_ROOT=$( cd `dirname $0`; pwd)
source $SCRIPT_ROOT/.env

GUEST_NAME=${1?"guest cluster name required"}; shift
GUEST_VIP=${1?"guest cluster vip required"};shift
tkg create cluster $GUEST_NAME -p prod -k v1.19.1+vmware.2   --vsphere-controlplane-endpoint-ip  $GUEST_VIP -c 1 -w 3
