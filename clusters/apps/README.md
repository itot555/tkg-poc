# Application Cluster Setup

1. Switch context
   ```
   kubectl config use-context poc-apps-admin@poc-apps
   ```
2. Deploy TMC extension constoller

kubectl apply -f tmc-extension-manager.yaml
