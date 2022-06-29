terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.11.0"
    }
  }
}

provider "azurerm" {
  features {}
  // Sub ID to be modified to fit environment
  subscription_id = "54sd5454-sd54-sd89-55sd-hjhjh84218ghg"
  tenant_id       = "hjhj5hjhj-54hh-jj66-88tt-985ghrtrt"
}

//variable "role_definition_id" {
//  type = map(any)
//  default = {
//    group1 = {
//      role_definition_name = "Key Vault Crypto Officer"
//      principal_id       = "4k5j45kj-kj45k45-4555-23jh-78kl7jjkl7jj" //userid
//    }
//    group2 = {
//      role_definition_name = "Key Vault Contributor"
//      principal_id       = "4k5j45kj-kj45k45-4555-23jh-78kl7jjkl7jj"
//    }
//    group3 = {
//      role_definition_name = "Key Vault Secrets Officer"
//      principal_id       = "4k5j45kj-kj45k45-4555-23jh-78kl7jjkl7jj"
//    }
//  }
//}

variable "role_definition_id" {
  type        = list(string)
  description = "Role definition id"
  default = ["Key Vault Crypto Officer","Key Vault Contributor","Key Vault Secrets Officer"] // https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
}

resource "azurerm_key_vault" "kv1" {
  name                        = "os1"
  location                    = "germanywestcentral"
  resource_group_name         = "os1"
  enabled_for_disk_encryption = true
  tenant_id                   = "hjhj5hjhj-54hh-jj66-88tt-985ghrtrt"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true

  sku_name = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    //ipRules               = []
    //virtualNetworkRules   = []
  }

  tags = {
    // refer to confluence naming and tagging convention but here is an example
    "DataClassification" = "internal"
    "Owner"              = "noc"
    "Platform"           = "noc"
    "Environment"        = "test"
  }
}

resource "azurerm_role_assignment" "kv1-roles" {
  for_each = toset(var.role_definition_id)
  role_definition_name = each.key
  //role_definition_id = each.key
  scope              = azurerm_key_vault.kv1.id
  principal_id = "4k5j45kj-kj45k45-4555-23jh-78kl7jjkl7jj" //userid
}

//resource "azurerm_role_assignment" "kv1-roles" {
//  for_each                         = var.role_definition_id
//  scope                            = azurerm_key_vault.kv1.id
//  role_definition_name             = each.value.role_definition_name
//  principal_id                     = each.value.principal_id
//}
