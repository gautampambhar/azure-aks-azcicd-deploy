environment="dev"
aks_version_prefix="1.23"

#ssh_public_key="$(sshkey.secureFilePath)"
system_pool_type="VirtualMachineScaleSets"

system_pool_vm_size="Standard_DS2_v2"
system_pool_autoscale_max_count=3
system_pool_autoscale_min_count=1
system_pool_os_disk_size_gb=30

linux_pool_vm_size="Standard_DS2_v2"
linux_pool_autoscale_max_count=3
linux_pool_autoscale_min_count=1
linux_pool_os_disk_size_gb=30

windows_pool_vm_size="Standard_DS2_v2"
windows_pool_autoscale_max_count=3
windows_pool_autoscale_min_count=1
windows_pool_os_disk_size_gb=30