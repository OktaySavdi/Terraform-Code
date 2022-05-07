terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.5.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-aks-resources"
  location = var.region
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "${var.prefix}-aks1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "${var.prefix}-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}