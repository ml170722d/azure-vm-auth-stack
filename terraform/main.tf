# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  client_id         = var.client_id
  client_secret     = var.client_secret
  tenant_id         = var.tenant_id
  subscription_id   = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "hylastix"
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${azurerm_resource_group.rg.name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create a virtual network subnet
resource "azurerm_subnet" "subnet" {
  name = "${azurerm_resource_group.rg.name}-subnet"
  address_prefixes = [ "10.0.1.0/24" ]
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# Create a network security group
resource "azurerm_network_security_group" "nsg" {
  name = "${azurerm_resource_group.rg.name}-nsg"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule = [ {
    name = "Allow-SSH"
    description = "Allow SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"

    source_port_range = "*"
    destination_port_range = "22"

    source_port_ranges = []
    destination_port_ranges = []

    source_address_prefix = "*"
    destination_address_prefix = "*"

    source_address_prefixes = []
    destination_address_prefixes = []

    source_application_security_group_ids = []
    destination_application_security_group_ids = []
  } ]
}

# Create a public IP address
resource "azurerm_public_ip" "pub_ip" {
  name = "${azurerm_resource_group.rg.name}-pub-ip"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name = "${azurerm_resource_group.rg.name}-nic"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pub_ip.id
  }
}

# Create a security group association
resource "azurerm_network_interface_security_group_association" "sng-association" {
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a linux virtial machine
resource "azurerm_linux_virtual_machine" "vm" {
  name = "${azurerm_resource_group.rg.name}-vm"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_B2ls_v2"
  admin_username = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    public_key = file(var.vm_admin_public_key_path)
    username = var.vm_admin_username
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "ubuntu-24_04-lts"
    sku = "server"
    version = "latest"
  }
}
