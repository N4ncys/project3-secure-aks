# Environment name — used to name resources consistently across deployments
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Azure region — canadacentral chosen to keep data in Canada
variable "location" {
  description = "Azure region"
  type        = string
  default     = "canadacentral"
}

# Main resource group that holds all project 3 resources
variable "resource_group_name" {
  description = "Name of the main resource group"
  type        = string
  default     = "rg-aks-secure-dev"
}

# AKS cluster name
variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-secure-dev"
}

# Kubernetes version — pin this to avoid unexpected upgrades
variable "kubernetes_version" {
  description = "Kubernetes version — pinned to avoid unexpected upgrades"
  type        = string
  default     = "1.30"
}

# VM size for all node pools — D2s_v3 is a good balance for dev
variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}