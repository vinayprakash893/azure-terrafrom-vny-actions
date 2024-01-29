terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      "source" = "hashicorp/azurerm"
      version  = "3.43.0"
    }
  }
  cloud {
    organization = "Cloudtech"

    workspaces {
      name = "cloud_user_p_c207c704"
    }
  }
}

provider "azurerm" {
  client_id       = var.ARM_CLIENT_ID
  subscription_id = var.ARM_SUBSCRIPTION_ID
  # Other Azure provider settings
  features {}
  skip_provider_registration = true
}

resource "random_string" "uniquestring" {
  length  = 20
  special = false
  upper   = false
}

# resource "azurerm_ressource_group" "rg" {
#   name     = "1-bfe2059c-playground-sffsaz"
#   location = "southcentralus"
# }

resource "azurerm_storage_account" "storageaccount" {
  name                     = "mystoragevnyacgtest"
  resource_group_name      = "1-8b740d85-playground-sandbox"
  location                 = "southcentralus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


variable "ARM_CLIENT_ID" {}
variable "ARM_SUBSCRIPTION_ID" {}

