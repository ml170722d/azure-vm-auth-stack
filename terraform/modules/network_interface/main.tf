# Create a network security group
resource "azurerm_network_security_group" "nsg" {
  name = "${var.name_prefix}-nsg"
  location = var.location
  resource_group_name = var.rg_name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                          = security_rule.key
      description                   = security_rule.key
      priority                      = security_rule.value.priority
      direction                     = security_rule.value.direction
      access                        = security_rule.value.access
      protocol                      = security_rule.value.protocol
      source_address_prefixes       = security_rule.value.source_address_prefixes
      destination_address_prefixes  = security_rule.value.destination_address_prefixes
      source_port_ranges            = security_rule.value.source_port_ranges
      destination_port_ranges       = security_rule.value.destination_port_ranges
      source_port_range             = security_rule.value.source_port_range
      destination_port_range        = security_rule.value.destination_port_range
      source_address_prefix         = security_rule.value.source_address_prefix
      destination_address_prefix    = security_rule.value.destination_address_prefix
    }
  }
}

# Create a public IP address
resource "azurerm_public_ip" "pip" {
  name = "${var.name_prefix}-pip"
  location = var.location
  resource_group_name = var.rg_name
  allocation_method = var.public_ip_type
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name = "${var.name_prefix}-nic"
  location = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name = "internal"
    subnet_id = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Create a security group association
resource "azurerm_network_interface_security_group_association" "sng-association" {
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
