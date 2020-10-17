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

# Prepare vSphere Environment
Follow instruction on official documentation to prepare vSphere for TKG installation


# Install TKG Management Cluster

At this point you should go to terminal/shell of you jumpbox and follow the the instructions below. 

## Clone this repo

```
git clone https://github.com/yogendra/tkg-poc ~/tkg-poc
cd ~/poc
```

## Copy packages

All the downloaded packages, not OVA files, should be copied to ~/poc/packages. You can use any preferred method(WinSCP/Mac Finder SSH connection/Filezilla)

## Setup `.env`

Automated setup

- Run init env script

  ```
  ./00-init-env.sh
  ```

Alternatively, you can setup `.env` manually

- Create a `.env` file

  ```
  touch .env
  ```

- Edit `.env` and add following settings

  - Set client name

    ```
    CLIENT=super-tech
    ```

  - Set Jumpbox IP (one provided by client)

    ```
    JUMPBOX_IP=10.1.2.3
    ```

  - Set POC Domain. This is generally one domain that you would use for multiple POC. Every client will have a subdomain under this.

    ```
    POC_DOMAIN=corp.local
    ```

## Init Jumpbox

  ```
  ./02-init-jumpbox.sh
  ```

- Run registry on jumpbox

  ```
  ./03-run-registry.sh
  ```

- Migrate images

  ```
  ./05-migrate-images.sh
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

- Cert Manager
- Contour
- Harbor
- DEX
- ELK

# Prepare Apps Cluster

- Gangway
- Fluent-bit
- Cert Manager
- Contour

# Install Applications




MetalLB
Create random secret
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" -o yaml --dry-run=client > metallb/02-secret-emberlist.yaml
