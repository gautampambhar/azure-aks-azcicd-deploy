# CICD pipeline

# TODO
- Create 2 service connection
    - docker service connection: Docker build and push it to the ACR
    - Kubernetes service connection: deploy images from ACR to AKS

## YAML Build pipeline 

1. Create Service Connection: for Docker build and push it to the ACR
    - Type: Docker registry
        - Azure container registry 
        - provide creds
        - provide registry name
        - SC name: manual-aksdevopsacr-svc
        - Description
        - Grant permission to all pipeline

2.  Create a starter pipeline
    - stage --> job --> steps
        - step1: Docker build and push images
            - Container registry: SC name
            - repo: Image name (any name)
            - Command: build and push
            - dockerfile: location
            - tags: build.BuildId/build.SourceVersion(commit id)
        - Step2: Copy File from '$(System.DefaultWorkingDirectory)/kube-manifests' and paste it to '$(Build.ArtifactStagingDirectory)'
        - Step3: PublishBuildArtifacts@1

## Release pipeline with 4 Envrionment
1. Create 4 Namespaces manually 
2. Create 4 Service Connection for each env
    - Type: Kubernetes
        - Cluster name
        - Namespace: dev (replace dev with appropreate environment)
        - Service Connection name: dev-ns-aks-sc (replace dev with appropreate environment)
3. Create release pipeline
    - add artifact
    - on release job add task
        - Task: deploy to Kubernetes
            - Name: Create secret to allow image pull from ACR
            - Action: create secret
            - Kubernetes Service Connection: dev-ns-aks-sc (replace dev with appropreate environment)
            - Namespace: dev (replace dev with appropreate environment)
            - Secret Name: dev-aksdevopsacr-secret (provide any name)
            - Docker service connection: manual-aksdevopsacr-svc (Created in the build stage)
        - Task: deploy to Kubernetes
            - Name: Deploy to AKS
            - Action: deploy
            - Kubernetes Service Connection: dev-ns-aks-sc (replace dev with appropreate environment)
            - Namespace: dev (replace dev with appropreate environment)
            - Strategy: none
            - Manifests: build artifact
            - Container Name: aksdevopsacr.azurecr.io/custom2aksnginxapp1:$(Build.BuildId) // Container registry/Image name(repository from docker@2 task from build pipeline):$(Build.BuildId)
            - Image pull Secret: secret name from above task
            - Docker service connection: manual-aksdevopsacr-svc (Created in the build stage)
        - Create Multiple stage as you want