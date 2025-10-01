# Main Terraform configuration for deploying an Azure AKS cluster
# Resources: Resource Group, VNet, Subnet, AKS Cluster with basic configuration
# Optimized for development/testing environments with cost-effective settings

# Generate random suffix for unique naming
resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.cluster_name}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Subnet for AKS
resource "azurerm_subnet" "aks" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefixes
}

# Log Analytics Workspace (required for monitoring if enabled)
resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enable_oms_agent ? 1 : 0
  name                = "${var.cluster_name}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.cluster_name}-${random_integer.suffix.result}"
  kubernetes_version  = var.kubernetes_version

  # Default node pool configuration
  default_node_pool {
    name                = "default"
    node_count          = var.enable_auto_scaling ? null : var.node_count
    min_count           = var.enable_auto_scaling ? var.min_count : null
    max_count           = var.enable_auto_scaling ? var.max_count : null
    enable_auto_scaling = var.enable_auto_scaling
    vm_size             = var.node_vm_size
    os_disk_size_gb     = var.os_disk_size_gb
    vnet_subnet_id      = azurerm_subnet.aks.id
    type                = "VirtualMachineScaleSets"
    
    # Cost optimization settings
    only_critical_addons_enabled = false
    temporary_name_for_rotation  = "temp"
  }

  # Identity configuration
  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = var.load_balancer_sku
    outbound_type     = "loadBalancer"
  }

  # Role-based access control (simplified for basic setup)
  role_based_access_control_enabled = var.enable_rbac

  # Monitoring (optional)
  dynamic "oms_agent" {
    for_each = var.enable_oms_agent ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id
    }
  }

  # Azure Policy (optional)
  azure_policy_enabled = var.enable_azure_policy

  tags = var.tags

  depends_on = [
    azurerm_subnet.aks
  ]
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Role assignment for AKS to manage the subnet
resource "azurerm_role_assignment" "aks_subnet" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}