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

resource "aws_s3_bucket" "s3_bucket" {
    bucket = "vinay-s3-demo-test11-demq12342" # change this
}

# module "storage_create"{
#     source = "git::ssh://git@ssh.dev.azure.com/v3/vinaycloudtech/cer/tf-modules"
#     #source = "git::ssh://git@github.com/vinayprakash893/terraform-module/"
#     #source = "git::ssh://git@github.com/vinayprakash893/terraform-module/modules/azure-storage-vny?ref=main"
#     #source = "./modules/azure-storage-vny"
# }
