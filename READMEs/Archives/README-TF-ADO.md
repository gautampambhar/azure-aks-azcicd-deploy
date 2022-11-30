# Terraform 

1. create blob storage and container to store backend tf.state file
    - This should be kept in separate Resource group(Other than your AKS resources)
2. Terraform code
    1. Resource Group name: aks-tf-{env}-rg


# TERRAFORM AND AZURE DEVOPS

## Goal
1. Create Azure DevOps Pipeline to create AKS cluster using Terraform
2. We are going to create two environments Dev and QA using single pipeline.
3. Terraform Manifests Validate
4. Provision Dev AKS Cluster
5. Provision QA AKS Cluster

## Prerequisites
- On your Azure DevOps project, navigate to marketplace store and install Azure Pipelines Terraform Tasks

## Steps

1. Review Terraform Manifests in your project
2. Create service connetion in ADO // for ADO to provision Terraform Infra on AKS cluster 
```
- Go to Project Settings
- Go to Pipelines -> Service Connections -> Create Service Connection
- Choose a Service Connection type: Azure Resource Manager
- Authentication Method: Service Princiapl (automatic)
- Scope Level: Subscription
- Subscription: Pay-As-You-Go
- Resource Group: LEAVE EMPTY
- Service Connection Name: aks-tf-dev-sc
- Description: Azure RM Service Connection for provisioning AKS Cluster using Terraform on Azure DevOps
- Security: Grant access permissions to all pipelines (check it - leave to default)
- Click on SAVE
```
3. Provide Permission to create Azure AD Groups
```
- Provide permission for Service connection created in previous step to create Azure AD Groups
- Open **aks-tf-dev-sc**
- Click on **Manage Service Principal**, new tab will be opened 
- Click on **View API Permissions**
- Click on **Add Permission**
- Select an API: Microsoft Graph
- Commonly used Microsoft APIs: Supported legacy APIs: **Azure Active Directory Graph-DEPRECATING**  Use **Microsoft Graph**
- Click on **Application Permissions**
- Check **Directory.ReadWrite.All** and click on **Add Permission**
- Click on **Grant Admin consent for Default Directory**
```
4. Create SSH Public Key for Linux VMs
- Create this out of your git repository 
- **Important Note:**  We should not have these files in our git repos for security Reasons
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

5. Upload file to Azure DevOps as Secure File
- Go to Azure DevOps -> Pipelines -> Library
- Secure File -> Upload file named **aks-terraform-devops-ssh-key-ububtu.pub**
- Open the file and click on **Pipeline permissions -> Authorize for use in all pipelines**
- Click on **SAVE**

## Auth through ADO

