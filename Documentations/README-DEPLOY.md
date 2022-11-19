# Create AKS cluster

link: https://github.com/stacksimplify/azure-aks-kubernetes-masterclass/tree/master/01-Create-AKS-Cluster 

- authentication method: system assigned managed identity (instead of service principal)
    - why? because service principal adds complexity(service principal eventually expire and the service principal must be renewed to keep the cluster working.) 
    - **how** to create: created automatically when you create clster
- networking: 
    - network policy: azure

## Have
- AKS cluster
    - when you create AKS cluster, an Azure standard load balancer gets cretaed, when you talk to the load node, this LB takes your request and forwards it to AKS node
    - Things to check on Azure: public IP addresses, LB
- Need: kubectl to connect to AKS through CloudShell/CLI/terminal

# Configure Kubectl to connect to AKS cluster 
1. Generate credentials to connect to AKS
```
Login to your AKS
- az aks get-credentials --resource-group aks-test-udemy-rg --name akstestudemycluster
- varify nodes: kubectl get nodes
```

# Troubleshoot pod
- kubectl describe pod [POD NAME] 
- kubectl logs [POD NAME] // pod logs
- kubectl logs -f [POD NAME] //access app to see logs
- kubectl exec -it [POD NAME] -- /bin/bash // connect to a container in a pod

# Update Deployment - Rolling
1. Set Image 
```
# Get Container Name from current deployment
kubectl get deployment my-first-deployment -o yaml

# Update Deployment - SHOULD WORK NOW
kubectl set image deployment/<Deployment-Name> <Container-Name>=<Container-Image> --record=true
kubectl set image deployment/my-first-deployment kubenginx=stacksimplify/kubenginx:2.0.0 --record=true
```
- Verify Rollout Status 
``` kubectl rollout status deployment/my-first-deployment ```

## how to go back to the older version of deployment
```
# Check the Rollout History of a Deployment
kubectl rollout history deployment/<Deployment-Name>
kubectl rollout history deployment/my-first-deployment  
```
2. Edit Deployment
```
# Edit Deployment
kubectl edit deployment/<Deployment-Name> --record=true
kubectl edit deployment/my-first-deployment --record=true
```
# Rollback deployment

## Check the Rollout History of a Deployment
```
# List Deployment Rollout History
kubectl rollout history deployment/<Deployment-Name>
kubectl rollout history deployment/my-first-deployment  
```

## Verify changes in each revision
- **Observation:** Review the "Annotations" and "Image" tags for clear understanding about changes.
```
# List Deployment History with revision information
kubectl rollout history deployment/my-first-deployment --revision=1
kubectl rollout history deployment/my-first-deployment --revision=2
kubectl rollout history deployment/my-first-deployment --revision=3
```
1. Previous version by Undo
- **Observation:** If we rollback, it will go back to revision-2 and its number increases to revision-4
```
# Undo Deployment
kubectl rollout undo deployment/my-first-deployment

# List Deployment Rollout History
kubectl rollout history deployment/my-first-deployment  
```
2. Specific version
```
# Rollback Deployment to Specific Revision
kubectl rollout undo deployment/my-first-deployment --to-revision=3
```
# Pause & Resume Deployments
- Why do we need Pausing & Resuming Deployments?
  - If we want to make multiple changes to our Deployment, we can pause the deployment make all changes and resume it. 

1. Pause Deployment and Two Changes
```
# Pause the Deployment
kubectl rollout pause deployment/<Deployment-Name>
kubectl rollout pause deployment/my-first-deployment

# Update Deployment - Application Version from V3 to V4
kubectl set image deployment/my-first-deployment kubenginx=stacksimplify/kubenginx:4.0.0 --record=true

# Check the Rollout History of a Deployment
kubectl rollout history deployment/my-first-deployment  
Observation: No new rollout should start, we should see same number of versions as we check earlier with last version number matches which we have noted earlier.

# Get list of ReplicaSets
kubectl get rs
Observation: No new replicaSet created. We should have same number of replicaSets as earlier when we took note. 

# Make one more change: set limits to our container
kubectl set resources deployment/my-first-deployment -c=kubenginx --limits=cpu=20m,memory=30Mi

### Resume Deployment 
```
# Resume the Deployment
kubectl rollout resume deployment/my-first-deployment

# Check the Rollout History of a Deployment
kubectl rollout history deployment/my-first-deployment  
Observation: You should see a new version got created

```
# callouts 
- if you pause deployment, and then make changes, it will not reflected or affcted the current application traffic
- in order to push them to production, you have to resume the depployment, once you update your deployment


## Kubectl apply to folder contains folder
```kubectl apply -R -f 02-context-based-routing```