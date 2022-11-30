# Create Windows Azure AKS Node Pool
# resource "azurerm_kubernetes_cluster_node_pool" "win101" {
#   zones    = [1, 2, 3]
#   enable_auto_scaling   = true
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
#   max_count             = var.windows_pool_autoscale_min_count
#   min_count             = var.windows_pool_autoscale_min_count
#   mode                  = "User"
#   name                  = "win101"
#   orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
#   os_disk_size_gb       = var.windows_pool_os_disk_size_gb
#   os_type               = "Windows" # Default is Linux, we can change to Windows
#   vm_size               = var.windows_pool_vm_size
#   priority              = "Regular"  # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
#   node_labels = {
#     "nodepool-type" = "user"
#     "environment"   = var.environment
#     "nodepoolos"    = "windows"
#     "app"           = "dotnet-apps"
#   }
#   tags = {
#     "nodepool-type" = "user"
#     "environment"   = var.environment
#     "nodepoolos"    = "windows"
#     "app"           = "dotnet-apps"
#   }
# }