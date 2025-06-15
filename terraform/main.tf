# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "mltfstatesa"
    container_name = "tfstate-hylastix"
    key = "hylastix.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  client_id         = var.client_id
  client_secret     = var.client_secret
  tenant_id         = var.tenant_id
  subscription_id   = var.subscription_id
}

provider "local" {}

module "rg" {
  source = "./modules/resource_group"
  name = "hylastix"
  location = var.location
}

module "vnet" {
  source = "./modules/network"
  rg_name = module.rg.rg_name
  location = var.location
  vnet_name = "hylastix-vnet"
  vnet_address_space = [ "10.0.0.0/16" ]
  subnet_configs = {
    "kc-subnet" = [ "10.0.1.0/24" ]
  }
}

module "nic" {
  source = "./modules/network_interface"
  name_prefix = "hylastix"
  location = var.location
  rg_name = module.rg.rg_name
  subnet_id = module.vnet.subnet_ids["kc-subnet"]
  security_rules = {
    "AllwoSSH" = {
      access = "Allow"
      priority = 1001
      direction = "Inbound"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = "22"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }
    "AllwoHTTP" = {
      access = "Allow"
      priority = 1002
      direction = "Inbound"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = "80"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }
    "AllwoHTTPS" = {
      access = "Allow"
      priority = 1003
      direction = "Inbound"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = "443"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }
  }
}

module "vm" {
  source = "./modules/compute"
  name = "hylastix-vm"
  location = var.location
  rg_name = module.rg.rg_name
  size = "Standard_B2ls_v2"

  admin_username = var.vm_admin_username
  admin_public_key = var.vm_admin_public_key

  nic_ids = [
    module.nic.nic_id
  ]
}

resource "local_file" "generate_ansible_hosts" {
  content = yamlencode({
    all = {
      hosts = {
        vm = {
          ansible_host = module.vm.pub_ip
          ansible_user = var.vm_admin_username
        }
      }
    }
  })
  filename = abspath("${path.module}/../ansible/hosts.yaml")
  file_permission = "640"
}

resource "null_resource" "run_ansible" {
  depends_on = [
    module.vm,
    fenelocal_file.generate_ansible_hosts
   ]

  provisioner "local-exec" {
    command = <<EOF
      echo "Running Ansible Playbook..."
      ansible-playbook \
        -i ${abspath("${path.module}/../ansible/hosts.yaml")} \
        ${abspath("${path.module}/../ansible/main.yaml")}
    EOF

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_PRIVATE_KEY_FILE  = abspath("${var.vm_admin_private_key_path}")
    }
  }
}
