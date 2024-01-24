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
      name = "cloud_user_p_816fb095"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "random_string" "uniquestring" {
  length  = 20
  special = false
  upper   = false
}

# resource "azurerm_resource_group" "rg" {
#   name     = "1-cdfddgffdf5-plyfgfgfddsound-sandbox"
#   location = "eastus"
# }

resource "azurerm_storage_account" "storageaccount" {
  name   = "test11vny111mydoamins"
  count                     = 50
  resource_group_name      = "1-cdcbf205-playground-sandbox"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


