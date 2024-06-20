#---------------------------------------------------------------------------
# Terraform state Configuration
#---------------------------------------------------------------------------

locals {
  backend_tier2_network = var.enable_tfc_remote_state ? data.terraform_remote_state.tfc_tier2_network["tfc_tier2_network"].outputs : data.terraform_remote_state.azure_tier2_network["azure_tier2_network"].outputs
}

data "terraform_remote_state" "tfc_tier2_network" {
  for_each = var.enable_tfc_remote_state ? toset(["tfc_tier2_network"]) : toset([])
  backend  = "remote"

  config = {
    organization = var.tfc_org
    workspaces = {
      name = var.tier2_tfc_workspace
    }
  }
}

data "terraform_remote_state" "azure_tier2_network" {
  for_each = var.enable_tfc_remote_state ? toset([]) : toset(["azure_tier2_network"])
  backend  = "azurerm"

  config = {
    resource_group_name  = var.tier2_remote_state_rg
    storage_account_name = var.tier2_remote_state_sa
    container_name       = var.tier2_remote_state_container
    key                  = var.tier2_remote_state_key
    subscription_id      = var.tier2_remote_state_sub_id
  }
}

locals {
  backend_tier3_aks_cluster = var.enable_tfc_remote_state ? data.terraform_remote_state.tfc_tier3_aks_cluster["tfc_tier3_aks_cluster"].outputs : data.terraform_remote_state.azure_tier3_aks_cluster["azure_tier3_aks_cluster"].outputs
}

data "terraform_remote_state" "tfc_tier3_aks_cluster" {
  for_each = var.enable_tfc_remote_state ? toset(["tfc_tier3_aks_cluster"]) : toset([])
  backend  = "remote"

  config = {
    organization = var.tfc_org
    workspaces = {
      name = var.tier3_tfc_workspace
    }
  }
}

data "terraform_remote_state" "azure_tier3_aks_cluster" {
  for_each = var.enable_tfc_remote_state ? toset([]) : toset(["azure_tier3_aks_cluster"])
  backend  = "azurerm"
  config = {
    resource_group_name  = var.tier3_remote_state_rg
    storage_account_name = var.tier3_remote_state_sa
    container_name       = var.tier3_remote_state_container
    key                  = var.tier3_remote_state_key
    subscription_id      = var.tier3_remote_state_sub_id
  }
}


locals {
  backend_tier1 = var.enable_tfc_remote_state ? data.terraform_remote_state.tfc_tier1_defaults["tfc_tier1_defaults"].outputs : data.terraform_remote_state.azure_tier1_defaults["azure_tier1_defaults"].outputs
}

data "terraform_remote_state" "tfc_tier1_defaults" {
  for_each = var.enable_tfc_remote_state ? toset(["tfc_tier1_defaults"]) : toset([])
  backend  = "remote"

  config = {
    organization = var.tfc_org
    workspaces = {
      name = var.tier1_tfc_workspace
    }
  }
}

data "terraform_remote_state" "azure_tier1_defaults" {
  for_each = var.enable_tfc_remote_state ? toset([]) : toset(["azure_tier1_defaults"])
  backend  = "azurerm"

  config = {
    resource_group_name  = var.tier1_remote_state_rg
    storage_account_name = var.tier1_remote_state_sa
    container_name       = var.tier1_remote_state_container
    key                  = var.tier1_remote_state_key
    subscription_id      = var.tier1_remote_state_sub_id
  }
}
