# Private container registry for storing and scanning images
resource "azurerm_container_registry" "main" {
  name                = "acraksecure${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Premium SKU required for private endpoints and content trust
  sku = "Premium"

  # Disable public access — only the cluster can pull images
  public_network_access_enabled = false

  # Content trust ensures only signed images can be pushed
  trust_policy {
    enabled = true
  }

  # Retention policy — automatically delete untagged images after 7 days
  retention_policy {
    days    = 7
    enabled = true
  }
}

# Allow the AKS cluster to pull images from the registry
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

# Private endpoint — connects the registry directly to the VNet
# This means image pulls never leave the Azure private network
resource "azurerm_private_endpoint" "acr" {
  name                = "pe-acr-aks-secure"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.aks_nodes.id

  private_service_connection {
    name                           = "psc-acr-aks-secure"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}
