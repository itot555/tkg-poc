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

set -e 
echo "Checking Docker runtime"
docker run --rm -t hello-world


docker ps | grep registry &&  docker rm -f registry


mkdir -p $PROJECT_ROOT/certs $PROJECT_ROOT/registry_data

if [[ ! -f $PROJECT_ROOT/certs/registry.crt ]] ; then
  mkcert \
    -cert-file $PROJECT_ROOT/certs/registry.crt \
    -key-file $PROJECT_ROOT/certs/registry.key \
    $JUMPBOX_IP central-registry.default.cluster.local central-registry.corp.local localhost 127.0.0.1
fi

docker run \
  --restart=always \
  --name registry \
  --hostname registry \
  -v $PROJECT_ROOT/registry_data:/var/lib/registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  -p 5000:5000 \
  -d \
  registry:2

echo "Tag for local registry hello-world => $LOCAL_REGISTY/hello-world"
docker tag hello-world ${LOCAL_REGISTRY}/hello-world

echo "Push image tp ${LOCAL_REGISTRY}/hello-world"
docker push ${LOCAL_REGISTRY}/hello-world

echo "Remove local cached images"
docker rmi -f  ${LOCAL_REGISTRY}/hello-world hello-world

echo "Pull from $LOCAL_REGISTRY/hello-world"
docker pull  ${LOCAL_REGISTRY}/hello-world

echo "Run image from $LOCAL_REGISTRY/hello-world"
docker run  --rm -t ${LOCAL_REGISTRY}/hello-world
