# Create a linux virtial machine
resource "azurerm_linux_virtual_machine" "vm" {
  name = var.name
  location = var.location
  resource_group_name = var.rg_name
  size = var.size
  admin_username = var.admin_username
  network_interface_ids = var.nic_ids

  admin_ssh_key {
    public_key = var.admin_public_key
    username = var.admin_username
  }

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}
