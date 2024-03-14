terraform {
  cloud {
    organization = "Cloudtech"

    workspaces {
      name = "azure-terraform-vny-github-actionsa"
    }
  }
}


provider "azurerm" {
    features {}
    skip_provider_registration = true
}

# resource "random_string" "uniquestring" {
#     length           = 25
#     special          = falsesasas
#     upper            = false
# }

# resource "azurerm_storage_account" "storageaccount" {
#   name                     = "mystoragfdevnyacgtests"
#   resource_group_name      = "1-95ecc417-playground-sandbox"
#   location                 = "southcentralus"
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }


# module "storage_create"{
#     source = "git::ssh://git@ssh.dev.azure.com/v3/vinaycloudtech/cer/tf-modules"
#     #source = "git::ssh://git@github.com/vinayprakash893/terraform-module/"
#     #source = "git::ssh://git@github.com/vinayprakash893/terraform-module/modules/azure-storage-vny?ref=main"
#     #source = "./modules/azure-storage-vny"
# }
