output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}

output "nsg_name" {
  value = azurerm_network_security_group.nsg.name
}

output "nic_id" {
  value = azurerm_network_interface.nic.id
}

output "nic_name" {
  value = azurerm_network_interface.nic.name
}

output "nsg_association_id" {
  value = azurerm_network_interface_security_group_association.sng-association.id
}
