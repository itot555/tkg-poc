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

tar -C $PROJECT_ROOT -xzvf packages/harbor-offline-installer-v2.1.0.tgz 
HARBOR_ROOT=$PROJECT_ROOT/harbor
HARBOR_DATA=$HARBOR_ROOT/data
cp $HARBOR_ROOT/harbor.yml.tmpl $HARBOR_ROOT/harbor.yml

mkdir -p $HARBOR_DATA/certs

mkcert \
    -cert-file $HARBOR_DATA/certs/localhost.crt \
    -key-file $HARBOR_DATA/certs/localhost.key \
    $JUMPBOX_IP central-registry.default.cluster.local central-registry.corp.local localhost 127.0.0.1
openssl x509 -inform PEM -in $HARBOR_DATA/certs/localhost.crt -out $HARBOR_DATA/certs/localhost.cert

cp $PROJECT_ROOT/certs/ca.crt $HARBOR_DATA/certs/ca.crt
openssl x509 -inform PEM -in $HARBOR_DATA/certs/ca.crt -out $HARBOR_DATA/certs/ca.cert



function harbor_value (){
  key=$1; shift
  value=$1; shift

  yq w -i $HARBOR_ROOT/harbor.yml "$key" $value
}
harbor_value 'hostname' $JUMPBOX_IP
harbor_value 'http.port' 5001
harbor_value 'https.port' 5000 
harbor_value 'https.certificate' $HARBOR_DATA/certs/localhost.cert
harbor_value 'https.private_key' $HARBOR_DATA/certs/localhost.key 
harbor_value 'harbor_admin_password' "VMware1!VMware1!"
harbor_value 'clair.updaters_interval' 12
harbor_value 'data_volume' $HARBOR_DATA

sed -i '89 a sudo chown -R $USER:$USER common docker-compose.yml' $HARBOR_ROOT/install.sh 
$HARBOR_ROOT/install.sh --with-trivy --with-chartmuseum --with-clair



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
