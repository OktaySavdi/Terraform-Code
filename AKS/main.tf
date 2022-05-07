terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.5.0"
    }
    # Random 3.x
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    # Azure Active Directory 1.x
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.22.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "random_pet" "aks_rg" {}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-${var.prefix}-resources"
  location = var.region
}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "logs-${random_pet.aks_rg.id}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  retention_in_days   = 30
}

# Create Azure AD Group in Active Directory for AKS Admins
#resource "azuread_group" "aks_administrators" {
#  display_name = "${azurerm_resource_group.aks_rg.name}-cluster-administrators"
#  description  = "Azure AKS Kubernetes administrators for the ${azurerm_resource_group.aks_rg.name}-cluster."
#}

# Datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location        = azurerm_resource_group.aks_rg.location
  include_preview = false
}

# Provision AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"


  default_node_pool {
    name                 = "systempool"
    vm_size              = var.size
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    #availability_zones   = [1, 2, 3]
    enable_auto_scaling    = var.node_pool.enable_auto_scaling
    max_count              = var.node_pool.max_count
    min_count              = var.node_pool.min_count
    os_disk_size_gb        = var.node_pool.os_disk_size_gb
    type                   = var.node_pool.type
    enable_node_public_ip  = var.node_pool.enable_node_public_ip
    max_pods               = var.node_pool.max_pods
    enable_host_encryption = var.node_pool.enable_host_encryption

    node_labels = {
      "nodepool-type" = var.node_labels.nodepool-type
      "environment"   = var.node_labels.environment
      "nodepoolos"    = var.node_labels.nodepoolos
      "app"           = var.node_labels.app
    }
    tags = {
      "nodepool-type" = var.node_labels.nodepool-type
      "environment"   = var.node_labels.environment
      "nodepoolos"    = var.node_labels.nodepoolos
      "app"           = var.node_labels.app
    }
  }

  # Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned"
  }

  # RBAC and Azure AD Integration Block
  #role_based_access_control {
  #  enabled = true
  #  azure_active_directory {
  #    managed                = true
  #    admin_group_object_ids = [azuread_group.aks_administrators.id]
  #  }
  #}

  # Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  tags = {
    Environment = var.environment
  }
}