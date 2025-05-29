# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location
}

# Create resource group delete lock
resource "azurerm_management_lock" "delete_lock" {
  count = var.enable_delete_lock ? 1 : 0
  name = "${var.name}-rg-delete-lock"
  scope = azurerm_resource_group.rg.id
  lock_level = "CanNotDelete"
  notes = "Prevent accidental deletion of RG and children"
}
