# Azure storage type 

## Concepts
1. Storage class: where you want to store data
    - storage class manifest // ```aks-azcicd/locals/manifests/database-AzDisk/storage-class-manifests```
    - system provisioned storage class - AKS default class for creating database ```aks-azcicd/locals/manifests/database-AzDisk/system-provisioned-manifests```
2. Persistant volum claim: this will needed storage to be created to store data from the pod(specify how much storage you need. ex: storage: 5Gi )
3. Persistant volum: this will create storage mentioned in the pvc
4. ConfigMap: run script when pod gets cretaed(to create database schema) 
5. Db Deployment: MySql, PostGres
6. Db Service: service to connect to sql

# Azure storage type/class
1. Azure disk

**WHAT**: to store database deployment-pod data 
**WHY**: pods are ephemeral. we need to persist database data

**Advantages**
- cost effective storage: handle unexpected traffic
- unmanched resiliency: 0% annual failure rate
- seamless scalability: dynamic scaling of disk performance on ultra disk storage
- built in securty: automatic encryption  


## Steps
-  ```kubectl get sc ``` - check if you have any storage class; ex: Azure, AWS
    - managed premium  
-  ```kubectl get pvc ``` - check if you have pvc and its status

**Disdvantages**
- complex setup to achieve HA, StatefulSet (master-master/master-slave setup: need to setup replication bw them)
    - only one pod can connect to one Azure disk
- no automatic backup % recovery
- no auto-upgrade MySql
- Logging and monitorning needs custom scripts

2. Azure MySql database

**WHAT**: External database to store database 
**WHY**: see below features
**HOW**: ExternalName service
**WHERE**: ```aks-azcicd/locals/manifests/mysql-deployment```
**Architecture**: (./Documentations/Images/mysql-deploy.png) 

## Features 
- built-in high availability 
- scale as needed within second
- secured to protect sensitive data at rest and in-motion
- auto backups and point-in time restore for up to 35 days
- enterprise grade security 

## Create MySQL Database on Azure
- servername: akstestudemydb
- admin username: dbadmin
- admin password: Igotam2711@Ca

## Step-04: Connect to MySQL Database
```
# Connect to MYSQL Database
kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -- mysql -h mysql -p dbpassword11

# Verify usermgmt schema got created which we provided in ConfigMap
mysql> show schemas;
```


3. Azure file

**WHAT**: to store files
**WHY**: to store static content(front end - Nginx application) 
**Architecture**: (./Documentations/Images/az-fileshare.png) 
**Type**
- custom azure file storage // ```aks-azcicd/locals/manifests/Azfile-deploy/custom-storage-manifests```
    - We will define our own custom storage class with desired permissions 
        - Standard_LRS - standard locally redundant storage (LRS)
        - Standard_GRS - standard geo-redundant storage (GRS)
        - Standard_ZRS - standard zone redundant storage (ZRS)
        - Standard_RAGRS - standard read-access geo-redundant storage (RA-GRS)
        - Premium_LRS - premium locally redundant storage (LRS)
    - system provioned azure file storage ```aks-azcicd/locals/manifests/Azfile-deploy/system-provisioned-manifests```
        - With default AKS created storage classes only below two options are available for us.
            - Standard_LRS - standard locally redundant storage (LRS)
            - Premium_LRS - premium locally redundant storage (LRS)  

## Deployment 
- We are going to mount the file share to a specific path `mountPath: "/usr/share/nginx/html/app1"` in the Nginx container
- Flow
    - create storage class
    - PVC
    - Nginx deployment
    - Nginx service
**Advantages**
- multiple container/pod can access to single file share

## Steps
- ``` kubectl get sc ``` : to check howmany storage class are there
    - azurefile

  
