# DEPLOY PRODUCTION GRADE CLUSTER

This deployment has 2 **PHASE** 
1. Build Docker images and produce artifact with Terraform and Kubernetes build files 
- Resources needed
    - Resource Group to store ACR
    - ACR
    - Create service connection
        - docker service connection: Docker build and push it to the ACR
2. Deploy Terraform resources and docker images to AKS
- Resources
    - Resource group to store tfstate file
    - Azure Storage Account and Container to store tfstate file
    - Create service connection
        - Kubernetes service connection: deploy images from ACR to AKS

Before deploying Teraform resources and Kubernetes manifests files to AKS, create the below resources, it will needed for pipeline execution. 

## Manual Resources 
### Azure Portal Manual Resources via script
execute the the `scripts/manualrs.sh` to create below resources.
1. Create Resource Group  // to store tfstate file 
    - aks-{ENV}-tfstate-rg
2. Create Azure blob storage account with container // to store tfstate file 
    - blob account: aks{ENV}tfstatesa, container: aks{ENV}tfstate
3. Create Resource Group // To put ACR inside
    - aks-{ENV}-acr-rg
4. Create Azure Container Registry 
    - akstfregistry

### Azure DevOps Manual Resources
1. Create Service Connection: for Terraform to deploy AKS cluster
    - Type: Azure Resource Manager
        - Authentication Method: Service Princiapl (automatic)
        - Resource Group: LEAVE EMPTY
        - Service Connection Name: aks-${ENV}-tfazrs-svc
        - Description: Azure RM Service Connection for provisioning AKS Cluster using Terraform on Azure DevOps
        - Grant permission to all pipeline
    - Provide above Service Connectio a Permissions to create Azure AD Groups
        - Click on Manage Service Principal, new tab will be opened
        - Click on View API Permissions
        - Click on Add Permission
        - Select an API: Microsoft Graph
        - Click on Application Permissions
        - Check Directory.ReadWrite.All and click on Add Permission
        - Check Group.ReadWrite.All and click on Add Permission
        - Check RoleManagement.ReadWrite.Directory and click on Add Permission
        - Click on Grant Admin consent for Default Directory
2. Create SSH Public Key for Linux VMs
```
# Create Folder
mkdir $HOME/ssh-keys-teerraform-aks-devops

# Create SSH Keys
ssh-keygen \
    -m PEM \
    -t rsa \
    -b 4096 \
    -C "azureuser@myserver" \
    -f ~/ssh-keys-teerraform-aks-devops/aks-terraform-devops-ssh-key-ububtu \

Note: We will have passphrase as : empty when asked

# List Files
ls -lrt $HOME/ssh-keys-teerraform-aks-devops
Private File: aks-terraform-devops-ssh-key-ububtu (To be stored safe with us)
Public File: aks-terraform-devops-ssh-key-ububtu.pub (To be uploaded to Azure DevOps)
```
3. Upload Public file to Azure DevOps as Secure File
- Go to Azure DevOps -> Org -> Project -> Pipelines -> Library
- Secure File -> Upload file named **aks-terraform-devops-ssh-key-ububtu.pub**
- Open the file and click on **Pipeline permissions -> Authorize for use in all pipelines**
- Click on **SAVE**

4. Create Service Connection: for ADO to connect to Azure portal resources (to Docker build and push it to the ACR)
    - Type: Docker registry 
        - Type: Azure container registry 
        - provide creds
        - provide registry name
        - SC name: aks-${ENV}-acrbuild-svc
        - Description: SVC for ACR
        - Grant permission to all pipeline

## Deploy the pipeline Phase 1

Deployment must be done in 2 phase 
- First deploy the AKS cluster and build docker file 
- 2nd phase will deploy manifest files to AKS cluster. but before that you'll need to create Service Connection for Kubernetes to deploy manifests files.
- **HOW**: go to `pipelines/aks-tf-ado-deploy.yml` and depploy the task till terraform apply. comment code after terraform apply. This is because AKS deployment needs Kubernetes service connection. And to create service connection it needs AKS cluster running, which will only be created after the first deployment.

- Next create below resources manually

5. Create Service Connection: for ACR to deploy manifests to AKS 
    - Type: Kubernetes
        - provide creds
        - provide registry name
        - SC name: aks-${ENV}-manifestsdeployment-svc 
        - Description: SVC for AKS
        - Grant permission to all pipeline
    - Create Service Connection for each env
        - Type: Kubernetes
            - Cluster name
            - Namespace: dev (replace dev with appropreate environment)
            - Service Connection name: aks-${ENV}-manifestsdeployment-svc  (replace dev with appropreate environment)

## Deploy the pipeline Phase 2
- **HOW**: go to `pipelines/aks-tf-ado-deploy.yml` comment out the pipeline code after terraform apply stage. and redeploy the pipeline. 

## Connect to AKS Cluster
```
# Setup kubeconfig
az aks get-credentials --resource-group <Resource-Group-Name>  --name <AKS-Cluster-Name>
az aks get-credentials --resource-group terraform-aks-dev  --name terraform-aks-dev-cluster --admin

# View Cluster Info
kubectl cluster-info

# List Kubernetes Worker Nodes
kubectl get nodes

# List services
kubectl get svc
```





