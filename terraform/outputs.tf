# Cluster name — needed to connect kubectl to the cluster
output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

# Resource group — needed for az aks get-credentials command
output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

# OIDC issuer URL — needed when setting up Workload Identity in later steps
output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

# Log Analytics Workspace ID — useful for verifying Defender is connected
output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

# ACR login server — needed when pushing and pulling images
output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

# Workload identity client ID — needed when annotating the Kubernetes service account
output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}