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

tkg get mc &>> /dev/null

cat <<EOF >> ~/.tkg/config.yaml
TKG_CUSTOM_IMAGE_REPOSITORY: $TKG_CUSTOM_IMAGE_REPOSITORY
TKG_CUSTOM_IMAGE_REPOSITORY_SKIP_TLS_VERIFY: $TKG_CUSTOM_IMAGE_REPOSITORY_SKIP_TLS_VERIFY
EOF

$PROJECT_ROOT/scripts/gen-publish-images.sh > $PROJECT_ROOT/scripts/publish-images.sh

sh $PROJECT_ROOT/scripts/publish-images.sh

