################################################ Step-00 ################################################
######################################## Create Resource Group ############################################

ENV=$1
AKS_REGION=eastus

# Create Resource Group
# Configurable: name, location
az group create \
	--name aks-$ENV-acr-rg \
	--location $AKS_REGION

# Create ACR
az acr create \
	--resource-group aks-$ENV-acr-rg \
	--name akstfregistry \
	--sku Basic \
	--location $AKS_REGION \
	--admin-enabled true

# Create Resource Group
# Configurable: name, location
az group create \
	--name aks-$ENV-tfstate-rg \
	--location $AKS_REGION


# Create Storage Account and Container
 az storage account create \
     --resource-group aks-$ENV-tfstate-rg \
     --location $AKS_REGION \
     --name aks${ENV}tfstatesa \
     --kind Storage \
     --sku Standard_LRS \
	 --encryption-services blob

key=$(az storage account keys list -g aks-$ENV-tfstate-rg -n aks${ENV}tfstatesa --query [0].value -o tsv)

az storage container create \
	--name aks${ENV}tfstate \
	--account-name aks${ENV}tfstatesa \
	--account-key $key


