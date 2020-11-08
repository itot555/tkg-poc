
# Telenor Microfinance Bank - Tanzu PoC


A PoC cluster is Tanzu cluster is setup with  Harbor, Ingress Controller, CertManager and RabbitMQ.

You should be able to push images to Harbor and run these images as Pods on Tanzu. 

## Access Tanzu Kubernetes Grid

Here is the kubeconfig file. You can stor the content in a file (Example: `smsportal.kubeconfig.yaml `) and set the `KUBECONFIG` variable to use this config when using kubectl. 

```bash
export KUBCONFIG=smsportal.kubeconfig.yaml 
kubectl get all
```
**OR on Windows** 

```cmd
SET KUBECONFIG=smsportal.kubeconfig.yaml
kubectl get all
```

### smsportal.kubeconfig.yaml
```yaml 
apiVersion: v1
kind: Config
clusters:
- name: poc-prod
  cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5ekNDQWJPZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJd01URXdNVEE1TURBeU0xb1hEVE13TVRBek1EQTVNRFV5TTFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTklqCjJiRjhwQWVhRVo5Z3ZUclV3K3Mva2Y2dndmbXJFSkZoM1BONTZOSGV4WDJCWmRtbHJETWQwWDljck5rSTVCQWMKY3NzTGpoSUNjeXVqTzFSQWs2SW1MMXpWYVBqQkVZNkRHRFpiNU03V3pFWExxVHpVTStpcWFIRDV5RkNOeHFzNAp3ZE91c0h0bUpmSnc5S3kwaUdDYTdLWWY2bjJlekpuaFVSK3BDVXN2VFFNaFY0emMrOFJtOHZ4bFpCQldPQ1h3ClQ4Z1h2R3pwSFBXQUJVZCtPc0VSZk5yUUFqTG9SUmhSSzRFN2hqL21hZFE0SEZvTExicUFZTkYwWFRiOW1uS24KNE5TQXZEdVVOaG82V0ZwS2tCQVZhOVBrTzFrQmhEZnE0UWEyOWxWaThMVjJTaUZDK2xEVEd6b3VGVnVUY09jTwpBU2MyTjVxcVFSYlpWTk0wMGo4Q0F3RUFBYU1tTUNRd0RnWURWUjBQQVFIL0JBUURBZ0trTUJJR0ExVWRFd0VCCi93UUlNQVlCQWY4Q0FRQXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSXdPT0JtbFM5dElkU0hPck9Gam9QV0UKblFoUEErYUk4c3RXOXhqdkVFcmFUU29LSFM3Rks3dmJOMWJhMCtxSU9TUitCb0JRWU5Ca0tMUTBQK1NzUS9KYQpLczJGbk5WTWdEZWl5T1Ywa1N3amZNUTh1eUZUaWhBQndoWStFSnc3OFRkN0dFZm96ckVRLzY1TDJXb001cTZBCkxpQmNKRU9lQk9JZFoxUkkva3ptZm9FM2UxeVV5UkNIaEdTWHRmb1l6R1NQd0xpK3ZnOXlTOG1xOXVaTFU3RlcKY2xNdUZwNEljOWErT3hUbWRXT095N0xjN2JJWldCdmhJM2hJaGx0Sm1BOHQyVXY3YnRublAvS0RHOFYwS2JzaApob3QvMFA1QUdXR0V5QXB4Q0t3NXhheWhubE9WVmJTakRVVEpOcFg5bmxNS3FGMnd2V1VrdDYwR2hldjRmQUk9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://10.172.16.176:6443
contexts:
- name: smsportal@poc-prod
  context:
    cluster: poc-prod
    namespace: default
    user: smsportal
current-context: smsportal@poc-prod
users:
- name: smsportal
  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6InVSVkNvSVRWei1PUUtaeG14V1JkZk9KQUN4cEdTR21oT2JEdU0xc2I3aWsifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InNtc3BvcnRhbC10b2tlbi1oNTZ2cCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJzbXNwb3J0YWwiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJiZjRlMGEyNi02NjA1LTQzMTMtYTE2My04ZmI3N2E1MTU4YjEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpzbXNwb3J0YWwifQ.Hxv6ZL8URUa2iwwG0CiyzOoPGy_RNaRq-RmTDtZVyn6Zp-9d7V9OxNZBQOGbFBJSx0qVe6v9VU41ADxaWrjB8gIE5yfj5qGmK1QiZuxK0knzXLf3DCIX97pElF153jJADvSYFP-TaQfg3WCDnASN4HXNx2iuZJ2eZkRtcYv53izRHRFwhFuuaA6bosMVUU_XUCaJhKHJYYR5N4fWhCSSs5DYmoqWpgY0RoiOxIRnQIwuy3iR1w8AQlYyccqbidMjgeXHVeo9ujEdLOiTMOn1AtqpSCDCzL5hOhpt3VX_DCZPneUS2Iccv9tXQgnn-qhMkQkrYv9iGLVb5drBXWO0zQ

```

## Access Harbor

Harbor is an image and helm chart repository. You can push you docker images and helm charts to it. 
Image Registry Credentials

| Setting      | Value                      |
|--------------|----------------------------|
| **URL**      | harbor.poc.telenorbank.com |
| **Username** | admin                      |
| **Password** | VMware1!                   |

**NOTE**: Add CA certificate to your CA trust store on linux/windows where you are running docker. 
Detailed instructions can be found at [here][1]

### ca.cer 
```
-----BEGIN CERTIFICATE-----
MIIEvTCCAyWgAwIBAgIQAndr/3eoDoZJx+kWDeZvBzANBgkqhkiG9w0BAQsFADB3
MR4wHAYDVQQKExVta2NlcnQgZGV2ZWxvcG1lbnQgQ0ExJjAkBgNVBAsMHW9zYm94
ZXNAb3Nib3hlcyAob3Nib3hlcy5vcmcpMS0wKwYDVQQDDCRta2NlcnQgb3Nib3hl
c0Bvc2JveGVzIChvc2JveGVzLm9yZykwHhcNMjAxMDIwMTE1ODI1WhcNMzAxMDIw
MTE1ODI1WjB3MR4wHAYDVQQKExVta2NlcnQgZGV2ZWxvcG1lbnQgQ0ExJjAkBgNV
BAsMHW9zYm94ZXNAb3Nib3hlcyAob3Nib3hlcy5vcmcpMS0wKwYDVQQDDCRta2Nl
cnQgb3Nib3hlc0Bvc2JveGVzIChvc2JveGVzLm9yZykwggGiMA0GCSqGSIb3DQEB
AQUAA4IBjwAwggGKAoIBgQC/JxkQuzNWGPJU9SyMIM1IBbZHFJnrbRiwXxJ0X94A
086zCAPwjGBuRmEAssJD39bh8mLipkBgpyMtMbefaSXdAJEPR3wltF/Tkkq6EBCo
uw3Pl3qZAvn67RMeXr4t3fHzb9XwINKWHlHP1LMd/aPkhBzHmP2EWASKx2uaGZqn
FNKKQuP+LrgbHzDyJj76TBsu/QeIu4fzz8tb2/lOeiBcANxktGncmEDHeozF4z5Q
Aa55rEVI4hYLz2MysYfdz+ScuZeLXLW+FaEz2NJfmKJ0ouxNJWLjqZH9dW1KGiZ2
I4lvDBfvFcK8HcY54W3Z38p5s/EnWDpJvcSKlVxqQ90si3D0F9R566npEAE/SYsb
cpS6ZVFjm7gviSq0r81eZrxr3SRXVFbYgl3ZjtBnCr89zUd7cOsq2Efpb6gZCw19
C2sve3JeNHvrOx6LcukmwjzhP4VkGjtXNnXkO9qG2cEI2FT5na5ZaRi/rVLSSuW8
4Rj83Voiphq78TKp4VgoSb8CAwEAAaNFMEMwDgYDVR0PAQH/BAQDAgIEMBIGA1Ud
EwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFDiEz0cVDtmRdbUYoIrJGAvY+/HUMA0G
CSqGSIb3DQEBCwUAA4IBgQA3NgTzfzVmHxsiifyOS0PeHq7bDoMjwbdzDmCf4DAe
UCxEFFxLba4cd2Bs1SBctd16YkO6DUHC8o5DYbqqVR2TRdq3GBIRawAR3rOijeOw
PgXkbHdJ+i5PUyuOt29hSt5J27iol2vmllGzmi/ryHadY8nHB/PS+8xiqYgilhx/
WLntG1soaNAAJVR44SDZgx8qzAbm0FuNmI019KCdstfWboKPrRTSw8EzavqaubEE
p7dO6CE91rSPmTokg+LXOdoCYpSyrDkktbhbYl51wEyNGEIqWSDVCUu18fm8oACB
KT5PQ1E3XKryDJR1QMQqbG6cvkv5XCbr0IJi+vkEeoEtjfec8WYDZ6m2Yyaf/fO3
aDEfhpvAI8Imvir6z3fakApC/OIG8ADx7f5ndGKDzbiGbu/RW2c/FXPDNyxlrFr7
MGxJZ5tDmeRIW+mLeDXN197KEMG6uB79gv4zazrMwdtgk3pJuCn6GfjciRAsh8IA
Zw1kQfRW3ZG1pRPqUut4NIk=
-----END CERTIFICATE-----
```

## Sample Docekr Commands

Login to harbor registry on Docker
```
docker login harbor.poc.telenorbank.local -u admin -p 'VMware1!'
```

Build your image:
```
docker build -t harbor.poc.telenorbank.local/library/smsportalgmt:latest .
```

**Or** You can tag an exiting image
```
docker tag localhost:5000/smsportalgmt harbor.poc.telenorbank.local/library/smsportalgmt:latest
```

Push image to harbor
```
docker push harbor.poc.telenorbank.local/library/smsportalgmt:latest
```


## Deploy Application on Tanzu

Tanzu is running a vanila kubernetes. You can deploy any workload that is Kubernetes compliant. 


Your deployment needs to have an `imagePullSecrets` for pulling images form Harbor. `admin` user credentials have been already created as `local-harbor`. See the [SMS Portal Deployment](#sms-portal-deployment) for exact usage. 

If you need to use persistance volumne, user `vsphere-3par` storage class. Please note it only support `ReadWriteOne` access mode obly. 


## Access Application Externally

You can expose a workload outside the cluster using a proper URL with TLS (https). 
1. Decide a DNS address (myapp.poc.telenorbank.local)
1. Raise a request to point your DNS address to Ingress controller IP (10.172.16.177)
1. Configure your ingress resource with the DNS name and service details (see [SMS Portal Deployment](#sms-portal-deployment) )
1. Put annotations to specify certificate issuer. (see [SMS Portal Deployment](#sms-portal-deployment) )


## Rabbit MQ 

Rabbit MQ service is running in the cluster currently.

| Setting          | Value                                                                                                 |
|------------------|-------------------------------------------------------------------------------------------------------|
| **RMQ URL**      | amqp://244g-_CXE6EKYKp3UKYaZo-oljzQWeim:2Pu3l3gsz8LQVHPMohyei23O2cD5dhMR@notification-rabbitmq-client |
| **Username**     | 244g-_CXE6EKYKp3UKYaZo-oljzQWeim                                                                      |
| **Password**     | 2Pu3l3gsz8LQVHPMohyei23O2cD5dhMR                                                                      |
| **Hostname**     | notification-rabbitmq-client                                                                          |


## SMS Portal Deployment 


```yaml

apiVersion: apps/v1
kind: StatefulSet
metadata:
   name: smsportal
spec:
  serviceName: smsportal
  replicas: 3
  selector:
    matchLabels:
      app: smsportal
  template:
    metadata:
      labels:
        app: smsportal
        version: "0.0.1"
    spec:
      imagePullSecrets:
        - name: local-harbor
      containers:
        - image: harbor.poc.telenorbank.local/library/smsportalgmt:latest
          name: smsportal
          ports:
          - containerPort: 9999
            name: http
          volumeMounts:
          - mountPath: /home/logs
            name: smsportal-logs
          - mountPath: /u01/appservice/sms_portal_files
            name: smsportal-uploads
          resources:
            limits:
              cpu: 1000m
              memory: 4000Mi
            requests:
              cpu: 500m
              memory: 1000Mi
      affinity:         
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - smsportal
              topologyKey: kubernetes.io/hostname     
  volumeClaimTemplates:
    - metadata:
        name: smsportal-logs
        annotations:
          volume.beta.kubernetes.io/storage-class: vsphere-3par
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi
    - metadata:
        name: smsportal-uploads
        annotations:
          volume.beta.kubernetes.io/storage-class: vsphere-3par
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: smsportal
spec:
  type: NodePort
  ports:
  - port: 80
    protocol: TCP
    targetPort: http
    nodePort: 30080
    name: http
  selector:
    app: smsportal
---
apiVersion: v1
kind: Service
metadata:
  name: smsportal-lb
spec:
  type: LoadBalancer
  ports:
  - port: 80
    protocol: TCP
    targetPort: http
    name: http
  selector:
    app: smsportal
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: smsportal  
  labels:
    app: smsportal
  annotations:
    cert-manager.io/cluster-issuer: internal-ca    
    kubernetes.io/ingress.class: contour
    kubernetes.io/tls-acme: "true"
spec:
  tls:
    - secretName: smsportal-tls
      hosts:
        - smsportal.poc.telenorbank.local
  rules:
    - host: smsportal.poc.telenorbank.local
      http:
        paths:
          - backend:
              serviceName: smsportal
              servicePort: http
    - http:
        paths:
          - backend:
              serviceName: smsportal
              servicePort: http

```


[1]: https://manuals.gfi.com/en/kerio/connect/content/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html




