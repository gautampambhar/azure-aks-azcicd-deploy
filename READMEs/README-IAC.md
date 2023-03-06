# Terraform setup 

**Concept** 
1. You directly connect with Azure via terminal using Azure CLI
2. you connect with Azure using Terraform: for this we need service principal(service account)
    1. create service principal 

**Tools**
1. Azure CLI: to interact with Azure from locally 

**Steps needed to run terraform**
1. Azure provider 
2. Authenticate  
    1. Locally: Azure CLI 
    2. CICD: SAMI or Service Principal(for interact with azure using terraform or the cli we need service account) 
3. Install Terraform 
4. Write terraform file to import the Azure rm module and then authenticate with Azure 
    1. Create Files
        1. main.tf
            1. provider 
        2. variable.tf
    2. Create Modules: stching together multiple terraform files. keeps main.tf simple



