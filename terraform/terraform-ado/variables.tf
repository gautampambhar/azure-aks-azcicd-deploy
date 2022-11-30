variable "aks_version_prefix" {
}

variable "system_pool_type" {
}

variable "system_pool_vm_size" {
}
variable "system_pool_autoscale_max_count" {
}
variable "system_pool_autoscale_min_count" {
}
variable "system_pool_os_disk_size_gb" {
}

variable "linux_pool_vm_size" {
}
variable "linux_pool_autoscale_max_count" {
}
variable "linux_pool_autoscale_min_count" {
}
variable "linux_pool_os_disk_size_gb" {
}

variable "windows_pool_vm_size" {
}
variable "windows_pool_autoscale_max_count" {
}
variable "windows_pool_autoscale_min_count" {
}
variable "windows_pool_os_disk_size_gb" {
}

variable "location" {
  type = string
  description = "Azure Region where all these resources will be provisioned"
  default = "eastus"
}

# Azure Resource Group Name
variable "resource_group_name" {
  type = string
  description = "This variable defines the Resource Group"
  default = "terraform-aks"
}

# Azure AKS Environment Name
variable "environment" {
  type = string  
  description = "This variable defines the Environment"  
  # default = "dev"
}

# SSH Public Key for Linux VMs
variable "ssh_public_key" {
  # default = "~/.ssh/aks-prod-sshkeys-terraform/aksprodsshkey.pub"
  description = "This variable defines the SSH Public Key for Linux k8s Worker nodes"  
}

# Windows Admin Username for k8s worker nodes
variable "windows_admin_username" {
  type = string
  default = "azureuser"
  description = "This variable defines the Windows admin username k8s Worker nodes"  
}

# Windows Admin Password for k8s worker nodes
variable "windows_admin_password" {
  type = string
  default = "P@ssw0rd1234@ga"
  description = "This variable defines the Windows admin password k8s Worker nodes"  
}