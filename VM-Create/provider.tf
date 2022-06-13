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
  subscription_id = "<sub_id>"
  tenant_id       = "<tenant_id>"
}
