# Introduction 
This project is created to get quickly started with Azure Kubernetes deployment, AKS with terraform as an Iac and Azure DevOps as a CICD pipeline. 

The project deploys a Kubernetes cluster with 3 node pools(system, user(Linux and Windows)) and deploys sample applications. As a part of the application, docker images are taken from the stacksimplified website blog. 

# Goal
The goal of this project is to quickly create the Azure Kubernetes infra with terraform and run application workloads on Azure with Multi-environment(dev, prod)

This project also has folders to understand the concepts of how ingress, Authentication with AAD, and persistent storage with Azure files, disk, and blog. This is kept in a dedicated folder inside `all-projects/` directory. 

# Readmes
This project also has readme files in the `RAEDMEs/` to quickly understand the components that requires with the Kubernetes deployment with Azure. This will give you the overall architecture used to deploy the entire solution with the CICD pipeline. 

# Deploy 
To deploy this project with the Azure YAML pipeline, please read `RAEDMEs/README-PROF-DEPLOY` and mimic the steps in your azure environments.  

# CICD Pipeline Features 
- Build and push application docker images to Azure Container Registry(ACR)
- Create multi-environment Azure AKS infrastruture with Terraform 
- Deploy Application Kubernetes manifests file to AKS 

# Auth 
- Assigned RBAC Roles with Terraform using Azure Active Directory to grant AKS access to respective teams.

# Credits 
- Few concepts are borrowed from the stacksimplify Udemy course
