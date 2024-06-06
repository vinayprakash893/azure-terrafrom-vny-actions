
resource "random_string" "uniquestring" {
  length  = 20
  special = false
  upper   = false
}

# resource "azurerm_resofurce_group" "rg" {
#   name     = "1-bfdfsgnd-ssasdbossssgggfxs"
#   location = "southcentralus"
# }

resource "azurerm_storage_account" "storageaccount" {
  name                     = "mystoragfdevnyacgtest"
  resource_group_name      = "1-c0b9cc9d-playground-sandbox"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


