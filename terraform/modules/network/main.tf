# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.vnet_address_space
}

# Create a virtual network subnets
resource "azurerm_subnet" "subnet" {
  for_each = var.subnet_configs

  name = each.key
  address_prefixes = each.value
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
}
