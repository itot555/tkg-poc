# Shared Cluster Setup


1.  Change to shared cluster context
    ```
    kubectl config use-context poc-shared-admin@poc-shared
    ```
1.  Deploy TMC extension constoller
    ```
    kubectl apply -f $PROJECT_ROOT/package/tkg-extensions-v1.2.0+vmware.1/extensions/tmc-extension-manager.yaml
    ```


