# VARIABLES
SUBSCRIPTION_ID=""
RESOURCE_GROUP="rg-aks-baseline"
LOCATION="eastus"
CLUSTER_NAME="aks-baseline"
VNET_NAME="vnet-aks-baseline"
VNET_ADDRESS_SPACE="10.10.0.0/16"
VNET_SUBNET_NAME="snet-"$CLUSTER_NAME
VNET_SUBNET_ADDRESS_SPACE="10.10.0.0/22"
ACI_SUBNET_NAME="snet-aci-"$CLUSTER_NAME
ACI_SUBNET_ADDRESS_SPACE="10.10.4.0/23"
LOGANALYTICS_NAME="log-"$CLUSTER_NAME
LOGANALYTICS_RETENTION_DAYS=30 #30-730

# LOGIN TO THE SUBSCRIPTION
az login 
az account set --subscription $SUBSCRIPTION_ID

# REGISTER THE AZURE POLICY PROVIDER
az provider register --namespace Microsoft.PolicyInsights

# REGISTER PROVIDERS FOR CONTAINER INSIGHTS
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.OperationalInsights

# REGISTER THE ENCRYPTION-AT-HOST FEATURE
az feature register --namespace Microsoft.Compute --name EncryptionAtHost

# CREATE THE RESOURCE GROUP
resourceGroupExists=$(az group exists --name "$RESOURCE_GROUP")
if [ "$resourceGroupExists" == "false" ]; then 
    echo "Creating resource group: "$RESOURCE_GROUP" in location: ""$LOCATION"
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
fi

# CREATE THE VNET
vnetExists=$(az network vnet list -g "$RESOURCE_GROUP" --query "[?name=='$VNET_NAME'].name" -o tsv)
if [ "$vnetExists" != "$VNET_NAME" ]; then
    az network vnet create --resource-group $RESOURCE_GROUP --name $VNET_NAME \
    --address-prefix $VNET_ADDRESS_SPACE
fi

# CREATE SUBNET FOR THE CLUSTER 
subnetExists=$(az network vnet subnet list -g "$RESOURCE_GROUP" --vnet-name $VNET_NAME --query "[?name=='$VNET_SUBNET_NAME'].name" -o tsv)
if [ "$subnetExists" != "$VNET_SUBNET_NAME" ]; then
    VNET_SUBNET_ID=$(az network vnet subnet create --resource-group $RESOURCE_GROUP --name $VNET_SUBNET_NAME \
    --address-prefixes $VNET_SUBNET_ADDRESS_SPACE --vnet-name $VNET_NAME --query id -o tsv)
else
    VNET_SUBNET_ID=$(az network vnet subnet list -g "$RESOURCE_GROUP" --vnet-name $VNET_NAME --query "[?name=='$VNET_SUBNET_NAME'].id" -o tsv)
fi

# CREATE SUBNET FOR AZURE CONTAINER INSTANCES (ACI)
subnetExists=$(az network vnet subnet list -g "$RESOURCE_GROUP" --vnet-name $VNET_NAME --query "[?name=='$ACI_SUBNET_NAME'].name" -o tsv)
if [ "$subnetExists" != "$ACI_SUBNET_NAME" ]; then
    ACI_SUBNET_ID=$(az network vnet subnet create --resource-group $RESOURCE_GROUP --name $ACI_SUBNET_NAME \
    --address-prefixes $ACI_SUBNET_ADDRESS_SPACE --vnet-name $VNET_NAME --query id -o tsv)
else
    ACI_SUBNET_ID==$(az network vnet subnet list -g "$RESOURCE_GROUP" --vnet-name $VNET_NAME --query "[?name=='$ACI_SUBNET_NAME'].id" -o tsv)
fi


# CREATE LOG ANALYTICS WORKSPACE
logAnalyticsExists=$(az monitor log-analytics workspace list --resource-group $RESOURCE_GROUP --query "[?name=='$LOGANALYTICS_NAME'].name" -o tsv)
if [ "$logAnalyticsExists" != "$LOGANALYTICS_NAME" ]; then
    az monitor log-analytics workspace create --resource-group $RESOURCE_GROUP \
    --workspace-name $LOGANALYTICS_NAME --location $LOCATION --retention-time $LOGANALYTICS_RETENTION_DAYS
fi


# VARIABLES
SYSTEM_NODE_VM_SIZE="Standard_D4ds_v4"
SYSTEM_NODE_OS_DISK_SIZE=100

# CREATE THE CLUSTER
aksClusterExists=$(az aks list -g $RESOURCE_GROUP --query "[?name=='$CLUSTER_NAME'].name" -o tsv)
if [ "$aksClusterExists" != "$CLUSTER_NAME" ]; then
    AKS_RESOURCE_ID=$(az aks create -g $RESOURCE_GROUP -n $CLUSTER_NAME \
    --generate-ssh-keys --location $LOCATION --node-vm-size $SYSTEM_NODE_VM_SIZE --nodepool-name systemtemp --node-count 1 \
    --node-osdisk-type Ephemeral --node-osdisk-size $SYSTEM_NODE_OS_DISK_SIZE --zones {1,2,3} \
    --network-policy calico --network-plugin azure --vnet-subnet-id $VNET_SUBNET_ID  --aci-subnet-name $ACI_SUBNET_NAME \
    --enable-managed-identity --enable-aad --enable-azure-rbac --enable-addons monitoring,azure-policy,virtual-node \
    --workspace-resource-id "/subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP/providers/microsoft.operationalinsights/workspaces/$LOGANALYTICS_NAME" \
    --yes --query id -o tsv --only-show-errors )  
else
    AKS_RESOURCE_ID=$(az aks show -g $RESOURCE_GROUP -n $CLUSTER_NAME --query id -o tsv --only-show-errors)
fi

# Create a dedicated system node pool and delete the one previously created as part of the cluster deployment.
SYSTEM_NODE_NAME="system"
SYSTEM_MIN_COUNT=2
SYSTEM_MAX_COUNT=5

aksSystemNodePoolExists=$(az aks nodepool list -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --query "[?name=='$SYSTEM_NODE_NAME'].name" -o tsv --only-show-errors)
if [ "$aksSystemNodePoolExists" != "$SYSTEM_NODE_NAME" ]; then
    az aks nodepool add -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME \
    --name $SYSTEM_NODE_NAME --node-vm-size $SYSTEM_NODE_VM_SIZE --enable-cluster-autoscaler \
    --node-osdisk-type Ephemeral --node-osdisk-size $SYSTEM_NODE_OS_DISK_SIZE --zones {1,2,3} \
    --max-count $SYSTEM_MAX_COUNT --min-count $SYSTEM_MIN_COUNT --mode System \
    --vnet-subnet-id $VNET_SUBNET_ID --max-surge 33% --node-taints CriticalAddonsOnly=true:NoSchedule 
    # delete the existing "temp" system  node pool
    az aks nodepool delete -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME -n systemtemp
fi

# Add a dedication user node pool for hosting our application pods
USER_NODE_NAME="user1"
USER_NODE_VM_SIZE="Standard_D4ds_v4"
USER_NODE_OS_DISK_SIZE=100
USER_MIN_COUNT=1
USER_MAX_COUNT=4

aksUserNodePoolExists=$(az aks nodepool list -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --query "[?name=='$USER_NODE_NAME'].name" -o tsv --only-show-errors)
if [ "$aksUserNodePoolExists" != "$USER_NODE_NAME" ]; then
    az aks nodepool add -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME \
    --node-osdisk-type Ephemeral --node-osdisk-size $USER_NODE_OS_DISK_SIZE --zones {1,2,3} \
    --name $USER_NODE_NAME --node-vm-size $USER_NODE_VM_SIZE --enable-cluster-autoscaler \
    --max-count $USER_MAX_COUNT --min-count $USER_MIN_COUNT --mode User \
    --vnet-subnet-id $VNET_SUBNET_ID --max-surge 33%
fi