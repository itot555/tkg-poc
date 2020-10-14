#!/usr/bin/env bash

SCRIPT_ROOT=$( cd `dirname $0`; pwd)
source $SCRIPT_ROOT/.env

set -e 
echo "Checking Docker runtime"
docker run --rm -t hello-world


docker ps | grep registry &&  docker rm -f registryhen


mkdir -p $SCRIPT_ROOT/certs $SCRIPT_ROOT/registry_data

if [[ ! -f $SCRIPT_ROOT/certs/domain.crt ]
then
  cat <<EOF >  $SCRIPT_ROOT/certs/openssl.conf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]

CN = $JUMPBOX_IP
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
IP.1 = $JUMPBOX_IP
EOF

  openssl req \
  -x509 \
  -newkey rsa:4096 \
  -sha256 \
  -days 390 \
  -nodes \
  -extensions 'v3_req' \
  -keyout $SCRIPT_ROOT/certs/domain.key \
  -out $SCRIPT_ROOT/certs/domain.crt \
  -config $SCRIPT_ROOT/certs/openssl.conf
fi

docker run \
  --restart=always \
  --name registry \
  --hostname registry \
  -v $SCRIPT_ROOT/registry_data:/var/lib/registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
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
