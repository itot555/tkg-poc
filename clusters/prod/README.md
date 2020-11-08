# PROD Cluster


Assumptions:

1.  Change to cluster dir

    ```
    cd $PROJECT_ROOT/clusters/prod
    ```

## Create cluster

1.  Change to management cluster context

    ```
    kubectl config use-context poc-mgmt-admin@poc-mgmt
    ```

1.  Generate cluster config YAML

    ```
    tkg create cluster poc-prod -p prod -k  v1.19.1+vmware.2   --vsphere-controlplane-endpoint-ip $SHARED_API  --worker-size extra-large --worker-machine-count 3 --controlplane-machine-count 3 --controlplane-size small -d > poc-prod.yaml
    ```

1.  Edit `poc-prod.yaml`/`VSphereMachineTemplate/poc-prod-worker` and change the `numCPUs` to `8`. See the updated snippet below:

    ```yaml
    apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
    kind: VSphereMachineTemplate
    metadata:
      name: poc-prod-worker
      namespace: default
    spec:
      template:
        spec:
          cloneMode: fullClone
          datacenter: /SkylineDataCenter
          datastore: /SkylineDataCenter/datastore/3parDataStore
          diskGiB: 80
          folder: /SkylineDataCenter/vm/TKG Production VMs
          memoryMiB: 32768
          network:
            devices:
            - dhcp4: true
              networkName: Prod-POC-VLAN122
          numCPUs: 8
          resourcePool: /SkylineDataCenter/host/POC Production Cluster/Resources/tkg-mgmt
          server: 10.200.49.210
          template: /SkylineDataCenter/vm/photon-3-kube-v1.19.1+vmware.2
    ```

1.  Create the cluster 
    
    ```
    kubectl apply -f poc-prod.yaml 
    ```
1.  Wait for the cluster to be created. You can monitor the progress with

    ```
    tkg get clusters
    ```
    or
    ```
    kubectl get cl,md,mhc,ma,ms,vsphereclusters,vspheremachines,vspheremachinetemplates,vspherevms -o wide --show-labels
    ```
1.  Ones cluster creation is finishd you can get the credentials

    ```
    tkg get  credentials poc-prod
    ```

## Install Addons

1.  Change context to prod cluter

    ```
    kubectl config use-context poc-prod-admin@poc-prod
    ```

1.  Install Storage Class

    1.  Install `vsphere-3par` storageclass
        
        ```
        kubectl apply -f storageclass/storageclass-vsphere-3par.yaml
        ```
    
    1.  Patch `deafult` storage class to **NOT** be default
        
        ```
        kubectl patch storageclass default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
        ```

    1.  Test storage class

        ```
        kubectl apply -f storageclass/vsphere-3par-test.yaml
        ```
    1.  Check PV and PVC
        ```
        kubectl get pv,pvc
        ```
    1.  Delete PVC
        ```
        kubectl delete pvc vsphere-3par-test-pvc
        ```
1.  Install Metrics Server

    ```
    kubectl apply -f metrics-server/metrics-server.yaml
    ```

1.  Install Cert Manager
    ```
    kubectl apply -f cert-manager/
    ```

1.  Install Fluentbit (Optional)

1.  Install MetalLB

    ```
    kubectl apply -f metallb/
    ```

1.  Install Contour
    
    1.  Migrate Helm Images

        ```
        migrate-images-helm bitnami/contour
        ```
    1.  Create Namespace

        ```
        kubectl create ns contour
        ```
    1.  Install Helm Chart

        ```
        helm -n contour  install \
            contour bitnami/contour   \
            --set global.imageRegistry=$LOCAL_REGISTRY  \
            --set fullnameOverride=contour   \
            --set envoy.service.type=LoadBalancer 
        ```
    1.  Get Contour LB service details
        ```
        kubectl get svc contour-envoy --namespace contour -w
        ```
        Or Just get IP address
        ```
        kubectl describe svc contour-envoy --namespace contour | grep Ingress | awk '{print $3}'
        ```
1.  Install Harbor
    1.  Migrate Helm Images

        ```
        migrate-images-helm bitnami/harbor

        migrate-image docker.io/bitnami/harbor-notary-server:2.1.0-debian-10-r29 $LOCAL_REGISTRY/bitnami/harbor-notary-server:2.1.0-debian-10-r29
        ```
    1.  Create Namespace

        ```
        kubectl create ns harbor
        ```
    1.  Create private CA cert secret
        ```
        kubectl -n harbor create secret tls internal-ca-tls --cert=$PROJECT_ROOT/certs/ca.crt --key=$PROJECT_ROOT/certs/ca.key
        ```
    1.  Install Helm Chart

        ```
        helm -n harbor  install \
            harbor bitnami/harbor \
            --values helm-values/harbor.yaml \
            --set global.imageRegistry=$LOCAL_REGISTRY 
        ```
    1.  Create image pull secret
        ```
        kubectl create secret docker-registry local-harbor \
            -n default \
            --docker-server=harbor.poc.telenorbank.local \
            --docker-username=admin \
            --docker-password="VMware1!"
        ```
        
1.  Install RabbitMQ Operator
    1.  Download kubectl addon
        ```
        curl -o $PROJECT_ROOT/bin/kubectl-rabbitmq "https://raw.githubusercontent.com/rabbitmq/cluster-operator/main/bin/kubectl-rabbitmq"
        ```
        
    1.  Change permission
        ```
        chmod a+x $PROJECT_ROOT/bin/kubectl-rabbitmq
        ```

    1.  Relocate images
        ```
        migrate-image rabbitmqoperator/cluster-operator:0.48.0 $LOCAL_REGISTRY/rabbitmqoperator/cluster-operator:0.48.0
        ```

    1.  Get deployment yaml
        ```
        curl -sSL https://github.com/rabbitmq/cluster-operator/releases/download/0.48.0/cluster-operator.yml -o rabbitmq-operator/cluster-operator.yaml
        ```
    1.  Update yaml with local registry image (Line 4111)
        ```
        image: 10.172.16.5:5000/rabbitmqoperator/cluster-operator:0.48.0
        ```
    1.  Apply deployment yaml 
        ```
        kubectl apply -f rabbitmq-operator/cluster-operator.yaml
        ```
1.  Create RabbitMQ Instance
    1.  Create instance
        ```
        kubectl apply  -f rabbitmq-operator/notification-rmq.yaml 
        ```
    1.  Get resources for cluster
        ```
        kubectl get all -l app.kubernetes.io/name=notification
        ```
1.  Performance RabbitMQ instance
    1.  Migrate image
        ```
        migrate-image pivotalrabbitmq/perf-test $LOCAL_REGISTRY/pivotalrabbitmq/perf-test
        ```
    1.  Run perf test
        ```
        instance=notification
        username=$(kubectl get secret ${instance}-rabbitmq-default-user -o jsonpath="{.data.username}" | base64 --decode)
        password=$(kubectl get secret ${instance}-rabbitmq-default-user -o jsonpath="{.data.password}" | base64 --decode)
        service=${instance}-rabbitmq-client
        rmq="amqp://${username}:${password}@${service}"
        echo "
            Username: ${username}
            Password: ${password}
        RMQ Hostname: ${service}
             RMQ URL: ${rmq}
        "
        kubectl run perf-test --image=$LOCAL_REGISTRY/pivotalrabbitmq/perf-test -- --uri "${rmq}"
        ```
        **OR** use rabbitmq subcommand. Edit `$PROJECT_ROOT/bin/kubectl-rabbitmq`, `perf-test` part to point to local registry. Now run follwing:
        ```
        kubectl rabbitmq perf-test notification --rate 100
        ```

## Patch for DNS

Current DNS is not accessible propely from the cluster so we need to manually add an entry for harbor in the `/etc/hosts`

```
kubectl get nodes -o json | jq .items[].status.addresses[1].address -r | while read ip; do
    ssh -o StrictHostKeyChecking=no capv@${ip}  -- echo 10.172.16.177 harbor.poc.telenorbank.local \| sudo tee -a  /etc/hosts
done
```
## Deploy Application

1.  SMS Portal
    1.  Tag Image
        ```
        docker tag 10.172.16.5:5000/smsportalgmt harbor.poc.telenorbank.local/library/smsportalgmt:latest
        ```
    1.  Push
        ```
        docker push  harbor.poc.telenorbank.local/library/smsportalgmt:latest
        ```
    1.  Deploy app

        ```
        kubectl apply -n default  -f smsportal/smsportal.yaml
        ```

## Service Account for App Developers

1.  Create service account
    ```
    create-app-user smsportal default
    ```

1.  Generate kubeconfig
    ```
    generate-sa-kubeconfig smsportal default > smsportal.kubeconfig.yaml
    ```





    

