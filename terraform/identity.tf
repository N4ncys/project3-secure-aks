# Log Analytics Workspace for collecting cluster logs and security alerts
# Defender for Containers requires this to send its findings somewhere
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-aks-secure-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"

  # 30 days is the minimum recommended retention for security auditing
  retention_in_days   = 30
}

# User assigned managed identity for the workload pods
# This is the Azure-side identity that gets permissions to Azure resources
resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-aks-workload-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Federated credential — links the Azure identity to a Kubernetes service account
# This is the bridge that lets pods authenticate to Azure without secrets
resource "azurerm_federated_identity_credential" "workload" {
  name                = "federated-aks-workload"
  resource_group_name = azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.workload.id
  audience            = ["api://AzureADTokenExchange"]

  # OIDC issuer URL from the cluster — proves the token came from our cluster
  issuer  = azurerm_kubernetes_cluster.main.oidc_issuer_url

  # The Kubernetes service account that is allowed to use this identity
  subject = "system:serviceaccount:app:workload-sa"
}

# Give the workload identity permission to read secrets from Key Vault
resource "azurerm_role_assignment" "workload_keyvault" {
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_resource_group.main.id
}