variable "name" {
  type = string
  description = "Compute instance name"
}

variable "location" {
  type = string
  description = "Azure region"
}

variable "rg_name" {
  type = string
  description = "Name of resource group where resources will be created"
}

variable "size" {
  type = string
  description = "Size of compute instance"
}

variable "admin_username" {
  type = string
  description = "Admin user"
}

variable "admin_public_key" {
  type = string
  description = "Admin public key"
}

variable "nic_ids" {
  type = list(string)
  description = "List of NIC ids associated with compute instance"
}

variable "os_disk" {
  type = object({
     caching = optional(string, "ReadWrite")
    storage_account_type = optional(string, "Standard_LRS")
  })
  description = "Compute instance os disk config"
  default = {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

variable "source_image_reference" {
  type = object({
    publisher = optional(string, "Canonical")
    offer = optional(string, "ubuntu-24_04-lts")
    sku = optional(string, "server")
    version = optional(string, "latest")
  })
  description = "Compute instance source image reference"
  default = {
    publisher = "Canonical"
    offer = "ubuntu-24_04-lts"
    sku = "server"
    version = "latest"
  }
}
