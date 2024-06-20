# -------------------------------------------------------------
# Required Providers
# -------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

locals {
  kube_config            = local.backend_tier3_aks_cluster.defaults.kube_config[0]
  host                   = local.kube_config.host
  username               = local.kube_config.username
  password               = local.kube_config.password
  client_certificate     = base64decode(local.kube_config.client_certificate)
  client_key             = base64decode(local.kube_config.client_key)
  cluster_ca_certificate = base64decode(local.kube_config.cluster_ca_certificate)

}
provider "kubernetes" {
  host                   = local.host
  username               = local.username
  password               = local.password
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = local.host
    username               = local.username
    password               = local.password
    client_certificate     = local.client_certificate
    client_key             = local.client_key
    cluster_ca_certificate = local.cluster_ca_certificate
  }

}

#-------------------------------------------------------------
# Data Reference
#-------------------------------------------------------------


data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

data "azuread_group" "ad_groups" {
  display_name     = var.team_aad_group
  security_enabled = true
}


#-------------------------------------------------------------
# Create Resource Groups
#-------------------------------------------------------------

module "rg" {
  source              = "git@github.com:dayforcecloud/terraform-azurerm-resource-group.git//?ref=v1.0.6"
  for_each            = var.namespace
  resource_group_name = join("-", [var.subscription, var.aks_purpose, var.environment, each.value.team_name, var.purpose, var.location])
  # app551-cam-np-dfcoreinfraeng-app98-eastus2" --application name need to remove 
  # var.subscription, each.value.team_name,var.environment, var.purpose, var.region_map_location[var.location]["location"]]
  location = var.location
  tags     = merge(var.tags, each.value.tags)
}

#-------------------------------------------------------------
# Create Action Group - Team
#-------------------------------------------------------------

locals {
  ag_name = "${var.subscription}-${var.aks_purpose_short}-${var.environment}-${var.team_name}-${var.region_map_location[var.location]["location"]}"

  action_groups = {
    "${local.ag_name}" = {
      short_name            = "${var.team_name}"
      resource_group_name   = module.rg["ns1"].resource_group_name
      enabled               = var.action_group_enabled
      action_group_webhooks = var.action_group_webhooks
      action_group_emails   = var.action_group_emails
      tags                  = var.tags
    }
  }

}

module "action_groups" {
  source        = "git@github.com:DayforceCloud/terraform-azurerm-alerting//modules/action_groups//?ref=v1.2.7"
  depends_on    = [module.rg]
  action_groups = contains(local.sre_appd_env_dpy, var.environment) ? local.action_groups : {}
}

#---------------------------------------------------------------------------
# Retrieve Action Group - SRE - Tier 1 Defaults
# This is used to add any team infra kit action with the SRE Action Group
# example : action group sre key name - "app151-cam-prod-defaults-eastus2-sre"
#---------------------------------------------------------------------------
locals {
  sre_appd_env_dpy          = ["prod"]
  action_group_sre_key_name = "${var.subscription}-${var.aks_purpose_short}-${var.environment}-defaults-${var.location}-sre"
  action_group_sre_id = can(local.backend_tier1) ? (
    can(local.backend_tier1.defaults.action_groups.action_groups["${local.action_group_sre_key_name}"].id) ? (
      local.backend_tier1.defaults.action_groups.action_groups["${local.action_group_sre_key_name}"].id
    ) : null
  ) : null
}


#---------------------------------------------------------------------------
#  UMI Creation
#---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "um_identity" {
  for_each            = var.namespace
  name                = each.value.umi_name
  resource_group_name = module.rg[each.key].resource_group_name
  location            = var.location
  tags                = merge(var.tags, each.value.tags)
}


resource "azurerm_federated_identity_credential" "oidc_aks_fed" {
  depends_on          = [azurerm_user_assigned_identity.um_identity]
  for_each            = var.namespace
  name                = "aksfederatedidentity-${each.value.name}"
  resource_group_name = module.rg[each.key].resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = local.backend_tier3_aks_cluster.defaults.oidc_issuer_url[0]
  parent_id           = azurerm_user_assigned_identity.um_identity[each.key].id
  subject             = "system:serviceaccount:${each.value.name}:workload-identity"
}


#--------------------------------------------------------
# Add UMI to correct IAM Role Assignments
#--------------------------------------------------------


resource "azurerm_role_assignment" "aks_cluster_user_umi" {
  for_each             = var.namespace
  depends_on           = [azurerm_user_assigned_identity.um_identity]
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_user_assigned_identity.um_identity[each.key].principal_id
}

resource "azurerm_role_assignment" "reader_user_umi" {
  for_each             = var.namespace
  depends_on           = [azurerm_user_assigned_identity.um_identity]
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.um_identity[each.key].principal_id
}
