resource "azurerm_kubernetes_cluster" "main" {
  name                    = var.cluster_name
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  dns_prefix              = var.cluster_name

  # Private cluster — API server has no public IP
  # kubectl can only be run from within the VNet
  private_cluster_enabled = true

  # Dedicated system node pool for kube-system components only
  # Workload pods go on a separate pool defined below
  default_node_pool {
    name                         = "system"
    node_count                   = 1
    vm_size                      = var.node_vm_size
    vnet_subnet_id               = azurerm_subnet.aks_nodes.id
    os_disk_type                 = "Managed"
    only_critical_addons_enabled = true
  }

  # Using managed identity so the cluster authenticates to Azure
  # without any credentials to manage or rotate
  identity {
    type = "SystemAssigned"
  }

  # Azure CNI gives every pod a real VNet IP
  # Calico must be set here — cannot be added after cluster creation
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    service_cidr   = "10.100.0.0/16"
    dns_service_ip = "10.100.0.10"
  }

# Azure AD integration — all cluster access goes through
  # the organization's identity provider, no local kubeconfig users
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  # Workload Identity — pods authenticate to Azure services
  # without secrets or connection strings
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  # Defender for Containers — runtime threat detection and
  # vulnerability scanning inside the cluster
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }
}

# Separate node pool for workloads
# Keeps app pods isolated from system components
resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.node_vm_size
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.aks_nodes.id
  os_disk_type          = "Managed"

  node_labels = {
    "nodepool-type" = "workload"
  }
}