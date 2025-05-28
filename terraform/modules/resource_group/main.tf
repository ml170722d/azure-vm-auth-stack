# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location
}

# Create resource group delete lock
resource "azurerm_management_lock" "delete_lock" {
  name = "${var.name}-rg-delete-lock"
  scope = azurerm_resource_group.rg.id
  lock_level = "CanNotDelete"
  notes = "Prevent accidental deletion of RG and children"
}
