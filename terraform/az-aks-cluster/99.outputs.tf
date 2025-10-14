# Outputs for Azure AKS Cluster deployment

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "kubernetes_version" {
  description = "Kubernetes version of the cluster"
  value       = azurerm_kubernetes_cluster.main.kubernetes_version
}

output "cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "node_resource_group" {
  description = "Name of the auto-generated resource group for AKS nodes"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "cluster_identity" {
  description = "Identity configuration of the AKS cluster"
  value = {
    type         = azurerm_kubernetes_cluster.main.identity[0].type
    principal_id = azurerm_kubernetes_cluster.main.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.main.identity[0].tenant_id
  }
}

output "network_profile" {
  description = "Network profile of the AKS cluster"
  value = {
    network_plugin    = azurerm_kubernetes_cluster.main.network_profile[0].network_plugin
    load_balancer_sku = azurerm_kubernetes_cluster.main.network_profile[0].load_balancer_sku
    service_cidr      = azurerm_kubernetes_cluster.main.network_profile[0].service_cidr
    dns_service_ip    = azurerm_kubernetes_cluster.main.network_profile[0].dns_service_ip
  }
}

output "kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kubectl_connection_command" {
  description = "Command to configure kubectl to connect to the AKS cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "cluster_dashboard_command" {
  description = "Command to access the Kubernetes dashboard (if enabled)"
  value       = "kubectl proxy"
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace (if monitoring is enabled)"
  value       = var.enable_oms_agent ? azurerm_log_analytics_workspace.main[0].id : null
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "cluster_public_ip" {
  description = "Public IP address of the AKS cluster load balancer"
  value = try(
    tolist(azurerm_kubernetes_cluster.main.network_profile[0].load_balancer_profile[0].effective_outbound_ips)[0],
    "No public IP available - cluster may use managed outbound connectivity"
  )
}

# Data source to get all public IPs in the node resource group
data "azurerm_public_ips" "aks_outbound" {
  depends_on          = [azurerm_kubernetes_cluster.main]
  resource_group_name = azurerm_kubernetes_cluster.main.node_resource_group
}

output "aks_outbound_ip" {
  description = "Actual outbound public IP address used by AKS"
  value       = try(data.azurerm_public_ips.aks_outbound.public_ips[0].ip_address, "IP not found or not yet created")
}