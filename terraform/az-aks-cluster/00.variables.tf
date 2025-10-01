# Variables for Azure AKS Cluster deployment
# This file defines all the input variables needed to deploy a basic AKS cluster

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-cluster"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.27.3"
}

variable "node_count" {
  description = "Initial number of nodes in the default node pool"
  type        = number
  default     = 1
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "node_vm_size" {
  description = "VM size for the nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the default node pool"
  type        = bool
  default     = false
}

variable "min_count" {
  description = "Minimum number of nodes when auto scaling is enabled"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of nodes when auto scaling is enabled"
  type        = number
  default     = 3
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "enable_rbac" {
  description = "Enable Kubernetes Role-Based Access Control"
  type        = bool
  default     = true
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy for AKS"
  type        = bool
  default     = false
}

variable "enable_oms_agent" {
  description = "Enable OMS agent for container monitoring"
  type        = bool
  default     = false
}

variable "network_plugin" {
  description = "Network plugin to use for networking"
  type        = string
  default     = "kubenet"
  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "load_balancer_sku" {
  description = "SKU for the load balancer"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["basic", "standard"], var.load_balancer_sku)
    error_message = "Load balancer SKU must be either 'basic' or 'standard'."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "AKS-Cluster"
    Owner       = "DevOps"
  }
}