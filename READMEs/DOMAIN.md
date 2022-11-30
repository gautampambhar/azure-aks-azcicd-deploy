# Delegate Domain to Azure DNS

# Terminalogies
1. Domain: is a unique name in the domain name system. ex: gautampambhar.com
    - gautampambhar.com may contain several DNS records such as mail.gautampambhar.com, www.gautampambhar.com, info.gautampambhar.com
2. DNS Zone: is used to host **DNS record** for a perticular domain

3. Azure Domain
- Azure is not a Domain Registrar(AWS is)
- Azure DNS allows you to host a **DNS zone** and manage the DNS record for a domain in Azure 

# TODO
- Learn to delegate a domain from AWS Route53 to Azure DNS by creating DNS Zones in Azure Cloud 

# what is delegating a domain 
- change nameserver from AWS to Azure nameserver

# Why migration 
- because we want to use ingress with SSL concept with host-based routing

# Steps
1. get a domain from AWS or GoDaddy
2. Create a hosted zone in Azure 
    - enter the domain name in the Name field
3. Take the name server from Azure hosted zone and update it in your domain Registrar

ns1-3123.azure-dns.com.
ns2-3322.azure-dns.net.
ns3-3313.azure-dns.org.
ns4-3321.azure-dns.info.