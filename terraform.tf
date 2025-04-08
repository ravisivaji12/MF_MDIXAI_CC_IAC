terraform {
  required_version = "1.11.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.21.1"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}