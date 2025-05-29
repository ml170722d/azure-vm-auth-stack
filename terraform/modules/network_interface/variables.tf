variable "location" {
  type = string
  description = "Azure region"
}

variable "rg_name" {
  type = string
  description = "Name of resource group where resources will be created"
}

variable "name_prefix" {
  type = string
  description = "Prefix for naming module resources"
}

variable "public_ip_type" {
  type = string
  default = "Static"
  description = "Type of public IP resourece. 'Static' or 'Dynamic'"
}

variable "subnet_id" {
  type = string
  description = "Subnet id used to configure NIC"
}

variable "security_rules" {
  type = map(object({
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_address_prefixes      = optional(list(string), [])
    destination_address_prefixes = optional(list(string), [])
    source_port_ranges           = optional(list(string), [])
    destination_port_ranges      = optional(list(string), [])
    source_port_range            = optional(string, "")
    destination_port_range       = optional(string, "")
    source_address_prefix        = optional(string, "")
    destination_address_prefix   = optional(string, "")
  }))
  default = {}
}
