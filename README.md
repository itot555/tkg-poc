# TKG PoC

This is a guide to setup a TKG environment with couple of clusters. 

It assumes:

1. TKG 1.2+
1. vSphere
1. Internet Restricted Environment
1. Internet connected jumpbox that will be accessible from TKG cluster

# Download packages
- tkg
- tkg extensions
- crash diagnostics
- OVA files 
- curl
- wget
- mkcert  (Optional) - Required if not internal/corporrate CA certificates given
  ```
  curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 \
    -o $PROJECT_ROOT/bin/mkcert; chmod a+x $PROJECT_ROOT/bin/mkcert
  mkcert -install
  ```  
- octant
  ```
  curl -L https://github.com/vmware-tanzu/octant/releases/download/v0.16.1/octant_0.16.1_Linux-64bit.tar.gz \
    | tar  --strip-components 1  -C $PROJECT_ROOT/bin -xzvf - octant_0.16.1_Linux-64bit/octant  \
    &&  chmod a+x $PROJECT_ROOT/bin/octant
  ```
- k9s
  ```
  curl -sSL https://github.com/derailed/k9s/releases/download/v0.22.1/k9s_Linux_x86_64.tar.gz | tar -C $PROJECT_ROOT/bin -xz k9s ; chmod a+x $PROJECT_ROOT/bin/k9s
  ```
- dive
  ```
  curl -sSL https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.tar.gz | tar -C $PROJECT_ROOT/bin -xz dive ; chmod a+x $PROJECT_ROOT/bin/dive
  ```

# Prepare vSphere Environment
Follow instruction on official documentation to prepare vSphere for TKG installation
- No firewall between Jumpbox to vCenter
- No firewall between cluster (management + workloads) to vCenter
- Network subnet for management and workload cluster
  - DHCP enabled
  - DHCP IP pool should be suficient to run all management and gues cluster VMs (master + worker + extra)
  - Reserved Ips in same subnet for VIPs


# Install TKG Management Cluster

At this point you should go to terminal/shell of you jumpbox and follow the the instructions below. 

## Clone this repo

```
git clone https://github.com/yogendra/tkg-poc ~/tkg-poc
cd ~/tkg-poc
direnv allow
```

## Copy packages

All the downloaded packages, not OVA files, should be copied to ~/tkg-poc/packages. You can use any preferred method(WinSCP/Mac Finder SSH connection/Filezilla)

**TODO/WIP**
1. Automate this with vmw-cli
1. Automate vCenter Tasks 
   1. Use creation 
   2. Permissin assignments
   3. OVA deploy  
   4. template conversion

## Corporate/Private CA

If you are going to use certificates signed by a private CA / corporate CA, copy its certificate to `$PROJECT_ROOT/certs/ca.crt`

## Jumpbox Preparations

1.  Initialize env 
    -  Run init env script

        ```
        01-init-env.sh
        ```
        **OR**
    - Alternatively, you can setup `.env` manually by copying `.env_sample`

      - Create a `.env` file

        ```
        cp .env_sample  .env
        ```

      - Edit `.env` and add following settings

        | Env Var                                     | Description                                                                                       |
        | ------------------------------------------- | ------------------------------------------------------------------------------------------------- |
        | CLIENT                                      | Chort client name. DNS compliant (no spacem, lowercase, no underscore)                            |
        | JUMPBOX_IP                                  | IP address of internet connected VM where images will be pulled and stores                        |
        | POC_DOMAIN                                  | Domain name sufix for POC  (Example: tkg-poc.corp.local)                                          |
        | ROOT_DOMAIN                                 | Internal Root Domain for infrastructure (Example: corp.local)                                     |
        | LOCAL_REGISTRY                              | Local private registry for initialization. This might be on Jumpbox (Example: <jumpbox_ip>:5000 ) |
        | TKG_CUSTOM_IMAGE_REPOSITORY                 | Same as LOCAL_REGISTRY                                                                            |
        | TKG_CUSTOM_IMAGE_REPOSITORY_SKIP_TLS_VERIFY | true if you are using private CA or http only                                                     |
        | GOVC_URL                                    | vCenter URL                                                                                       |
        | GOVC_INSECURE                               | State true if vcenter  is using private CA certs                                                  |
        | GOVC_USERNAME                               | vCenter username (Example: administrator@vsphere.local)                                           |
        | GOCV_PASSWORD                               | vCenter password                                                                                  |
        | VMWUSER                                     | My VMware Username                                                                                |
        | VMWPASS                                     | My VMware Password                                                                                |
        | MGMT_API                                    | Management Cluster - Kubernetes API / Control Plain VIP (Example: 192.168.1.100)                  |
        | MGMT_LB_RANGE                               | Management Cluster - LoadBalancer Service IP Range (Example: 192.168.101-192.168.105)             |
        | SHARED_API                                  | Shared Cluster - Kubernetes API / Control Plain VIP (Example: 192.168.1.106)                      |
        | SHARED_LB_RANGE                             | Shared Cluster - LoadBalancer Service IP Range  (Example: 192.168.107-192.168.110)                |
        | APPS_API                                    | Application Cluster - Kubernetes API / Control Plain VIP (Example: 192.168.1.111)                 |
        | APPS_LB_RANGE                               | Application Cluster - LoadBalancer Service IP Range  (Example: 192.168.112-192.168.115)           |
        

2.  Init Jumpbox

    ```
    02-init-jumpbox.sh
    ```

3.  Run registry on jumpbox

    ```
    03-run-registry.sh
    ```

4.  Migrate images

    ```
    04-migrate-tkg-images.sh
    ```


## Prepare TKG Config

Add private/internal CA to the plans

1.  Copy CA certificate and overlay files to`~/.tkg/providers/infrastructure/vsphere/ytt` directory
    ```
    cp $PROJECT_ROOT/overlay/providers/infrastructure-vsphere/ytt/internal-ca.yaml $PROJECT_ROOT/certs/ca.crt ~/.tkg/providers/infrastructure-vsphere/ytt/    
    ```

# Setup TKG config using UI
1.  Run GUI wizard to prepare TKG Config and deploy management cluster
    ```
    05-tkg-create-mc.sh
    ```
1.  Open a browser on Windows/Mac/Linux GUI
1.  Follow the wizard until all the config steps are done
1.  Subsequently, you can run following to initialized the cluster, as you TKG config is setup by the wizard
    ```    
    tkg init -i vsphere --vsphere-controlplane-endpoint-ip $MGMT_API -p dev --ceip-participation true --name poc-mgmt --cni antrea -v 10
    ```
2.  (Optional) Monitor/Examine/Troubleshoot bootstrap cluster:
    - Open a new terminal
    - Goto Project root
    - Set bootstrap KIND kubernetes cluster config as the `KUBECONFIG` for the shell
      ```
      export KUBECONFIG=`ls -1rt $HOME/.kube-tkg/tmp/config* | tail -1`
      ```
    - Run any kubernetes command to monitor. 
    - Example: Get Pods list and watch it
      ```
      kubectl get po -A -w
      ```
3.  (Optional) Monitor/Examing/Troubleshoot management cluster during initializatio:
    - Wait for Kind cluster to be fully initialized. Look for a log entry in the initialization output similar to following
      ``` 
      Start Creating Management Cluster
      ```
    - Set management context
      ```
      kubectl config use-context poc-mgmt-admin@poc-mgmt
      ```
    - Run any kubernetes command to monitor. 
    - Example: Get Pods list and watch it
      ```
      kubectl get po -A -w
      ```
    - SSH into a cluster VM. If you have provided default RSA publisc key during initialization `~/.ssh/id_rsa.pub` then you can use:
      ```
      ssh -i ~/.ssh/id_rsa capv@<IP Address>
      ```
## Guest Cluster: Shared Services

### Create 

- On the shell run following command to create a guest cluster

  - Provide Guest Cluster Name and Endpoint VIP ip in arguments

    ```
    06-tkg-create-guest-cluster.sh poc-shared $SHARED_API
    ```
- Get Kubernetes cluster credentials
  ```
  tkg get credentials poc-shared 
  ```
### In Cluster Services

- Storage Class  
- Metal LB
- Cert Manager
- Contour
- Harbor
- DEX (Optional)
- ELK (Optional)


## Guest Cluster: Applications

### Create 

- On the shell run following command to create a guest cluster

  - Provide Guest Cluster Name and Endpoint VIP ip in arguments

  ```
  ./06-tkg-create-guest-cluster.sh poc-apps $APP_API
  ```
- Get Kubernetes cluster credentials
  ```
  tkg get credentials poc-apps 
  ```
### In Cluster Services

- Storage Class  
- Metal LB
- Cert Manager
- Contour
- Fluentbit



## Get TKG 1.2 Extensions
Refer to [Shared Services and Extension Setup Guide][tkg-1-2-extensions-doc] for details instructions. Here is a [quick link][tkg-1-2-extension-setup] to exact download page.

1.  Download extensions from [My VMware][tkg-1-2-extension-setup] into `$PROJECT_ROOT/packages` folder
2.  Unpack the tar file 
  
    ```
    tar -C $PROJECT_ROOT/packages -xzvf $PROJECT_ROOT/packages/tkg-extensions-manifests-v1.2.0+vmware.1.tar.gz
    ```
  
    This will create a folder `tkg-extensions-v1.2.0+vmware.1` with all the manifests files in it
3.  Relocate TKG images
    ```
    grep -RiIl --color=never --include=\*.yaml  'projects.registry.vmware.com' $EXTENSION_ROOT \
        | xargs -I yamlfile grep projects.registry.vmware.com yamlfile \
        | awk {'print $2'} \
        | while read image \
        do
            echo Migrating $image
            migrate-image  $image
        done
    ```

4.  Update image references in the extensions to your LOCAL_REGISTRY
    
    ```
    grep -RiIl --color=never --include=\*.yaml  'projects.registry.vmware.com' $EXTENSION_ROOT | xargs sed -i "s/projects.registry.vmware.com/$LOCAL_REGISTRY/g"
    ```







## Install Cert Manager

Use Helm
```
migrate-images-helm  jetstack/cert-manager
```
Create Self sign CA

## Install Contour

Migrate Images
```
migrate-images-helm  bitnami/contour
```
Install Contour
```
k create ns contour
```
Deploy contour
```
helm -n contour  install contour bitnami/contour \
  --set global.imageRegistry=10.172.16.5:5000 \
  --set fullnameOverride=contour \
  --set envoy.service.type=LoadBalancer 
```

## Install Harbor

Migrate Images
```
migrate-images-helm  bitnami/harbor
```
Create Namespace

```
k create ns harbor
```

Create ineternal CA cert
```
k create -n harbor  secret generic  internal-ca-tls --from-file=ca.crt=$PROJECT_ROOT/certs/ca.crt 
```
Install chart

```
helm -n harbor install \
  harbor bitnami/harbor \
  -f $PROJECT_ROOT/deployments/harbor-values.yaml \
  --set ingress.host.core=harbor.$POC_DOMAIN \
  --set ingress.host.notary=notary.$POC_DOMAIN \
  --set global.imageRegistry=$LOCAL_REGISTRY

```


## Install EFK



### WIP Install Extensions



#### TMC Extension Manager

- Install TMC Extentions manager

  ```
  k apply -f $EXTENSION_ROOT/extensions/tmc-extension-manager.yaml
  ```

- Install Kapp Controller

  ```
  k apply -f $EXTENSION_ROOT/extensions/kapp-controller.yaml
  ```
- Install Cert Manager
  ```
  k apply -f $EXTENSION_ROOT/cert-manager/
  ```
- Install Metal LB
 
- Install Contour
  - Namespace Role
    ```
    k apply -f $EXTENSION_ROOT/extensions/ingress/contour/namespace-role.yaml
    ```
  - Create data values
    ```
    cp $EXTENSION_ROOT/extensions/ingress/contour/vsphere/contour-data-values.yaml.example \
     $EXTENSION_ROOT/extensions/ingress/contour/vsphere/contour-data-values.yaml
    ```
  - Create data value obejct
    ```
    k create secret generic contour-data-values --from-file=values.yaml=$EXTENSION_ROOT/extensions/ingress/contour/vsphere/contour-data-values.yaml -n tanzu-system-ingress
    ```
  - Deploy Contour
    ```
    k apply -f $EXTENSION_ROOT/extensions/ingress/contour/contour-extension.yaml
    ```
--
### MetalLB


Follow instructions at [MetalLB Doc](https://metallb.universe.tf/installation/)

- Enable strict ARP
  ```
  kubectl get configmap kube-proxy -n kube-system -o yaml | \
    sed -e "s/strictARP: false/strictARP: true/" | \
    kubectl apply -f - -n kube-system
  ```
- Relocate Images
  ```
  migrate-image metallb/speaker:main ${LOCAL_REGISTRY}/metallb/speaker:main
  migrate-image metallb/controller:main ${LOCAL_REGISTRY}/metallb/controller:main
  ```
- Update deployment manifest
  In `$PROJECT_ROOT/deployments/metallb/02-deployment.yaml` update image reference to use the local registry
  ```
  sed -i "s#image: metallb/speaker:main#image: ${LOCAL_REGISTRY}/metallb/speaker:main#"   $PROJECT_ROOT/deployments/metallb/02-deployment.yaml
  sed -i "s#image: metallb/controller:main#image: ${LOCAL_REGISTRY}/metallb/controller:main#"   $PROJECT_ROOT/deployments/metallb/02-deployment.yaml
  ```
- Create Namespace
  ```
  k apply -f $PROJECT_ROOT/deployments/metallb/01-namespace.yaml
  ```
- Update metallb config `clusters/<cluster>/metallb/config.yaml
  - Update the address pool for the LB IPs
  - Create ConfigMap
    ```
    k create cm -n metallb-system  config --from-file=config=$PROJECT_ROOT/clusters/<cluster>/metallb/config.yaml
    ```
    - Management
      ```
      k create cm -n metallb-system  config --from-file=config=$PROJECT_ROOT/clusters/mgmt/metallb/config.yaml
      ```
    - Shared
      ```
      k create cm -n metallb-system  config --from-file=config=$PROJECT_ROOT/clusters/shared/metallb/config.yaml
      ```
    - Apps
      ```
      k create cm -n metallb-system  config --from-file=config=$PROJECT_ROOT/clusters/apps/metallb/config.yaml
      ```
- Create MetalLB secret
  ```
  k create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" 
  ```

- Deploy metallb
  ```
  k apply -f $PROJECT_ROOT/deployments/metallb/02-deployment.yaml
  ```
