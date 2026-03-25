resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual network that the AKS cluster lives inside
resource "azurerm_virtual_network" "main" {
  name                = "vnet-aks-secure"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/8"]
}

# Subnet for AKS nodes — Azure CNI allocates pod IPs from this range
# Needs to be large enough to cover nodes and all their pods
resource "azurerm_subnet" "aks_nodes" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.240.0.0/16"]
}

# Subnet for Azure Bastion — name must be exactly "AzureBastionSubnet"
# This is how we securely access the private cluster without a public IP
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.241.0.0/27"]
}