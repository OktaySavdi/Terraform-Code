terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Configuration options
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}
# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = var.azurerm_virtual_network
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
# Create subnet
resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.azurerm_subnet
}
# Create public IPs
resource "azurerm_public_ip" "public" {
  name                = "${var.prefix}-public"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "allow-ssh" {
  name                = "${var.prefix}-resources"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = var.security_rule.name
    priority                   = var.security_rule.priority
    direction                  = var.security_rule.direction
    access                     = var.security_rule.access
    protocol                   = var.security_rule.protocol
    source_port_range          = var.security_rule.source_port_range
    destination_port_range     = var.security_rule.destination_port_range
    source_address_prefix      = var.security_rule.source_address_prefix
    destination_address_prefix = var.security_rule.destination_address_prefix
  }
  tags = {
    environment = var.environment
  }
}
# Create network interface
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.allow-ssh.id
}
# Create virtual machine
resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  os_disk {
    storage_account_type = var.os_disk.storage_account_type
    caching              = var.os_disk.caching
  }
  admin_ssh_key {
    username   = var.username
    #public_key = file(var.public-key)
    public_key = tls_private_key.example_ssh.public_key_openssh
  }
}
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}