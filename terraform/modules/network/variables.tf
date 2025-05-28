variable "location" {
  type = string
  description = "Azure region"
}

variable "rg_name" {
  type = string
  description = "Name of resource group where resources will be created"
}

variable "vnet_name" {
  type = string
  description = "Vitrual network name"
}

variable "vnet_address_space" {
  type = set(string)
  description = "Set of address spaces used by vnet"
}

variable "subnet_configs" {
  type = map(list(string))
  description = "Map of subnet names -> list of address prefixes"
  default = {}
}
