# Test Cluster Setup


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
    grep -RiIl --color=never --include=\*.yaml  'projects.registry.vmware.com' $PROJECT_ROOT/packages/tkg-extensions-v1.2.0+vmware.1 \
        | xargs -I yamlfile grep projects.registry.vmware.com yamlfile \
        | awk {'print $2'} \
        | while read image \
        do
            echo $migatin $image
            migrate-image  $image
        done
    ```

4.  Update image references in the extensions to your LOCAL_REGISTRY
    
    ```
    grep -RiIl --color=never --include=\*.yaml  'projects.registry.vmware.com' $PROJECT_ROOT/packages/tkg-extensions-v1.2.0+vmware.1 | xargs sed -i "s/projects.registry.vmware.com/$LOCAL_REGISTRY/g"
    ```

## Install TMC Extension

1. Change to cluster context  
2. Change tmage references and apply tmc-extensions
   
    ```    
    kubectl apply -f  $PROJECT_ROOT/packages/tkg-extensions-v1.2.0+vmware.1/extensions/tmc-extension-manager.yaml
   
    ```

3. 
4. Metal LB
5. Contour




# Install Metrics Server



# Install Metal Load Balancer


# Install TMC Entensions




[tkg-1-2-extensions-doc]: https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.2/vmware-tanzu-kubernetes-grid-12/GUID-extensions-index.html
[tkg-1-2-extension-setup]: https://my.vmware.com/en/group/vmware/downloads/details?downloadGroup=TKG-120&productId=988&rPId=53095
[tkg-installers]:  https://www.vmware.com/go/get-tkg
