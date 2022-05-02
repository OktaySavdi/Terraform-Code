variable environment {
  default     = "staging"
}

variable "prefix" {
  default     = "example"
}

variable "location" {
  default     = "northeurope"
}

variable "size" {
  type        = string
  default     = "Standard_D2as_v5"
}

variable "source_image_reference" {
  type = map(string)
  default = {
    "publisher" = "Canonical"
    "offer"     = "UbuntuServer"
    "sku"       = "18.04-LTS"
    "version"   = "latest"
  }
}

variable "os_disk" {
  type = map(string)
  default = {
    "storage_account_type" = "Standard_LRS"
    "caching"              = "ReadWrite"
  }
}

variable "security_rule" {
  type = map(string)
  default = {
    "name"                       = "allow-ssh"
    "priority"                   = 100
    "direction"                  = "Inbound"
    "access"                     = "Allow"
    "protocol"                   = "Tcp"
    "source_port_range"          = "*"
    "destination_port_range"     = "*"
    "source_address_prefix"      = "*"
    "destination_address_prefix" = "*"
  }
}

variable "azurerm_virtual_network" {
  default = ["10.0.0.0/22"]
}

variable "azurerm_subnet" {
  default = ["10.0.2.0/24"]
}

variable "username" {
  type        = string
  default     = "adminuser"
}

variable "password" {
  type        = string
  default     = "P@ssw0rd1234!"
}