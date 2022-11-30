# Ingress

**WHAT**
- ingress is a Kubernetes resource that lets us configure an HTTP load balancer for applications running on Kubernetes with an advanced capability set HTTP layer.
- Entry point to cluster - for all the requests to domain and subdomain rules that you configured
- Evaluates all the rules (define in the ingress component) - you may have 50 rules or 50 ingress component created in the cluster. So this Evaluates and decides which forwarding rule applies for that specific request  
- Manages redirection

**WHY**
- when you have multi microservices deployed with Kub service for each of them, it will create public address for each of them. if you want to access application using single IP instead of 3 separate service IP address, then no out of the box feature is there. 
- Azure standard LB: it doesn't have SSL termination. Because it's layer 4 LB, it only deal with the TCP traffic and not the HTTP traffic

**Ingress**
- You need a mechanism where you have one static public IP that acts as a entry point and all your service is attched to this IP.

## Features
- TLS/SSL termination(process of decrypting encrypted traffic before passing it along to a web server.) 
- context part-based routing
- host name-based routing.

**Ingress Terminalogy**
(../Images/ingress-terminalogy.png) 

**HOW**
- Create static public IP address
- install ingress controller using Helm
    - Use Helm to deploy an NGINX ingress controller // point Static IP
- create ingress service(redirection of application happens here)

**Architecture**: 
1. context-routing: (../Images/ingress-context-routing.png)

### Domain/DNS & SSL Certificate 
After purchasing domain, you need SSL cerficate from certificate authority(CA) to encrypt, authentication and HTTPS purposes. 

**How**: CA(let's encrypt, harshi corp) issue and sign the certificate and you need to install and activated on site's origin server  

2. hostname routing: (../Images/ingress-host-routing.png)
    - you create domain(DNS) in AWS/GoDaddy - atleast 1
        - delegate the domain name in Azure DNS zone
    - you manage the domain on Hosted Zone in Azure
        - you have 2 host name in your ingress service and that hosts needs to be updated in the Azure DNS host as a record
    - install **external DNS** (from Kubernetes itself, it is going to register your DNS host in your ingress file, whenever you deploy your Ingress manifest. We don't need to go to DNS Zones and add the record sets for our applications. Automatically, external DNS is going to do for us)
        - implemenet following
        1. how we are going to add all these three record sets(ex: 3 service with 3 host name) in DNS Zones  
        2.  **MSI**: how the permission from Azure AKS cluster to DNS Zones for this respective part to add DNA Zones using manager service identity.
        - TODO
        1. whenever we create an Ingress resource, it is going to create three DNS names,
        2. and those three DNS names are going to be registered to DNS Zones with a record set here.
        3. And in addition to that, whenever you access eapp1 it goes to App1, eapp2.kubeoncloud.com, it goes to App2, and eapp3.kubeoncloud.com, will go to App3, whatever it is, user management web app.
    - **SSL**: application needs SSL to incrypt data. 
    - **Let's incrypt**: is a Certificate Authority that provides free TLS/SSL certificate using the ACME (Automatic Certificate Management Environment ) protocol 
        - **how**: by running a **certificate management agent** on the web server. First, the agent proves to the CA that the web server controls a domain. Then, the agent can request, renew, and revoke certificates for that domain.
    - **Cert-manager**: is a native Kubernetes certificate management controller which helps with issuing certificates from a variety of sources. It will ensure certificates are valid and up to date, and attempt to renew certificates at a configured time before expiry. 
        - Cert manager, takes generated CSR certificate and submit to Let's incrypt automatically
    
    - **CALLOUTS**: so whenever you create Ingress manifest,  it creates the certificate-related secrets for your sapp1 and then sapp2. And then those SSL certificates means like, it will generate a CSR and using the Cert-manager, it will submit to Let's Encrypt automatically and then it will bring the valid SSL certificates and then deploy on our Kubernetes for our applications. so your application got the SSL certificates in the background automatically.

## TODO 1
1. create a domain name 
2. Create Azure DNS zone
    - delegate domain name in Azure DNS zone
    - have: you have 2 host in ingress
3. Install External DNS
    - **What**: takes your 2 host in your ingress(eapp1.gautamprojects.tech and eapp2.gautamprojects.tech) and update it's record set in Azure DNS host automatically
        - Host name will be **automatically DNS registered inside the DNS zones**
        - Which means **its record set is created automatically** 
    - Need permission: **MSI** 
4. Create MSI: this is permission needed from AKS to take ingress host and update it in the Azure DNS zone
    - Create MSI in Azure // take client id and paste it in the azure.json file
        - assign "Azure role assignement"
    - Create azure.json file
    - In Azure, VMSS --> identity --> add a created identity in the user assigned tab
5. Deploy External DNS: inorder for External DNS to work
    - manifest file 
6. Cert manager: issuing certificates from a Let's incrypt
    - link: https://medium.com/nerd-for-tech/k8s-cert-manager-and-lets-encrypt-a05f4d724927
    - it submit the CSRs to Let's incrypt and gets and apply certificate to our DNS host
    ### Cert-manager steps 
    1. install cert manager using helm package manager
        - create a namespace for cert-manager
        - install helm 
        - Add the jetstack helm repository
        - update the helm repositories
        - Install the cert-manager using helm package manager
    2. deploy a cert-manager issuer 
        - Create a yaml file include setup issuer K8s component
        - Deploy the issuer on your app namespace using kubectl
        - configure our ingress rule to use the issuer and defined a name for the new generated certificate
    3. deploy the ingress rule
    4. flow: ingress service with TLS setting --> cert-manager --> let's incrypt 


## TODO 2
1. create a DNS records set in Azure hosted zone

1. create managed service identity 
2. using MSI, link DNS zone and virtual machine scale set of Azure AKS cluster, stating in such a way that any of these services inside Azure AKS cluster(means like any pod or any application hosted under the virtual machine present inside this virtual machine scale set) will be able to update.
    - Means create, update or anything it can do on the DNS zones record sets. So it can create a record set, it can delete the record set, whatever it is. All this will be achieved by MSI
3. deploy External DNS: So ExternalDNS pod need to go ahead and then update the record sets whenever we deploy the Ingress.
4. deploy nginx app
5. create ingress service with host eapp1.kubeoncloud.com


## Terminalogies
### Delegate Domain to Azure DNS
1. Domain: is a unique name in the domain name system. ex: gautampambhar.com
    - gautampambhar.com may contain several DNS records such as: mail.gautampambhar.com, www.gautampambhar.com, info.gautampambhar.com
2. DNS Zone: is used to host **DNS record** for a perticular domain

3. Azure Domain
- Azure is not a Domain Registrar(AWS is)
- Azure DNS allows you to host a **DNS zone** and manage the DNS record for a domain in Azure 

#### TODO
- Learn to delegate a domain from AWS Route53 to Azure DNS by creating DNS Zones in Azure Cloud 

###### what is delegating domain 
- change nameserver from AWS to Azure nameserver

###### Why migration 
- because we want to use ingress with SSL concept with host based routing

###### Steps
1. get a domain from AWS or GoDaddy
2. Create a hosted zone in Azure 
    - enter domain name in the Name field
3. Take name server from Azure hosted zone and update it in your domain Registrar
