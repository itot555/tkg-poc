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
- mkcert  
  ```
  curl -sSL https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 > $PROJECT_ROOT/bin/mkcert; chmod a+x $PROJECT_ROOT/bin/mkcert
  mkcert -install
  ```  
- octant
  ```
  curl -sSL https://github.com/vmware-tanzu/octant/releases/download/v0.16.1/octant_0.16.1_Linux-64bit.tar.gz  |  tar  --strip-components 1  -C $PROJECT_ROOT/bin -xzvf - octant_0.16.1_Linux-64bit/octant  &&  chmod a+x $PROJECT_ROOT/bin/octant
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
```

## Copy packages

All the downloaded packages, not OVA files, should be copied to ~/tkg-poc/packages. You can use any preferred method(WinSCP/Mac Finder SSH connection/Filezilla)

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

1.  Init Jumpbox

    ```
    02-init-jumpbox.sh
    ```

1.  Run registry on jumpbox

    ```
    03-run-registry.sh
    ```

1.  Migrate images

    ```
    04-migrate-tkg-images.sh
    ```


## Prepare TKG Config


Add private/internal CA to the plans

Edit `$HOME/.tkg/providers/infrastructure-vsphere/v0.7.1/ytt/base-template.yaml`

1.  Update controle-plane template
   
    - Look for object with following begining

      ```
      apiVersion: controlplane.cluster.x-k8s.io/v1alpha3
      kind: KubeadmControlPlane
      metadata:
        name: '${ CLUSTER_NAME }-control-plane'
        namespace: '${ NAMESPACE }'
      ```
    - Add ca cert using `files`
     
        ```
              - content: |
                  -----BEGIN CERTIFICATE-----
                  <CA CERTIFICATE>
                  -----END CERTIFICATE-----
                owner: root:root
                path: /etc/ssl/certs/internal-ca.pem
        ```
    - Update `preKubeadmCommands`
      - Add rehash commands
      - Add containerd restart

        ```
            preKubeadmCommands:
            - hostname "{{ ds.meta_data.hostname }}"
            - echo "::1         ipv6-localhost ipv6-loopback" >/etc/hosts
            - echo "127.0.0.1   localhost" >>/etc/hosts
            - echo "127.0.0.1   {{ ds.meta_data.hostname }}" >>/etc/hosts
            - echo "{{ ds.meta_data.hostname }}" >/etc/hostname
            - /usr/bin/rehash_ca_certificates.sh
        ```
2.  Update worker template
    - Look for object with following begining
      ```
      apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
      kind: KubeadmConfigTemplate
      metadata:
        name: '${ CLUSTER_NAME }-md-0'
        namespace: '${ NAMESPACE }'
      ```
    - Add ca cert and prekubeadm commands
      ```
            files:
            - content: |
                -----BEGIN CERTIFICATE-----
                <CA CERTIFICATE>
                -----END CERTIFICATE-----
              owner: root:root
              path: /etc/ssl/certs/internal-ca.pem  
            preKubeadmCommands:
            - hostname "{{ ds.meta_data.hostname }}"
            - echo "::1         ipv6-localhost ipv6-loopback" >/etc/hosts
            - echo "127.0.0.1   localhost" >>/etc/hosts
            - echo "127.0.0.1   {{ ds.meta_data.hostname }}" >>/etc/hosts
            - echo "{{ ds.meta_data.hostname }}" >/etc/hostname          
            - /usr/bin/rehash_ca_certificates.sh
      ```
     
# Setup TKG config using UI
- Run GUI wizard to prepare `~/.tkg/config.yaml`
  ```
  ./05-tkg-create-mc.sh
  ```
- Open a browser on Windows/Mac/Linux GUI
- Follow the wizard until all the config steps are done


# Create Guest Cluster

- On the shell run following command to create a guest cluster

  - Provide Guset Cluster Name and Endpoint VIP ip in arguments

  ```
  ./06-tkg-create-guest-cluster.sh tkg-cluster-1 10.213.187.198
  ```

# Prepare Shared Cluster

- Storage Class  
- Metal LB
- Cert Manager
- Contour
- Harbor
- DEX (Optional)
- ELK (Optional)

# Prepare Apps Cluster

- Storage Class  
- Metal LB
- Cert Manager
- Contour
- Gangway
- Fluent-bit
- Cert Manager
- Contour

# Install Applications




MetalLB
Create random secret
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" -o yaml --dry-run=client > metallb/02-secret-emberlist.yaml




grep -RiIl 'registry.tkg.vmware.run' | xargs sed -i "s/registry.tkg.vmware.run/$TKG_CUSTOM_IMAGE_REPOSITORY/g"
