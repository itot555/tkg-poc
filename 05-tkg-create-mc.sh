#!/usr/bin/env bash

SCRIPT_ROOT=$( cd `dirname $0`; pwd)
source $SCRIPT_ROOT/.env

tkg init --ui --bind $JUMPBOX_IP:9080 --browser none -v 10
