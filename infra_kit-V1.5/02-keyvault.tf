#---------------------------------------------------------------------------
#  Keyvault
#---------------------------------------------------------------------------


module "kv" {
  source              = "git@github.com:dayforcecloud/terraform-azurerm-keyvault.git//?ref=v1.0.14"
  for_each            = var.enable_keyvault == true ? var.keyvault : {}
  resource_group_name = module.rg[each.value.ns_key].resource_group_name
  keyvault_name       = var.keyvault_name != null ? var.keyvault_name : "${var.subscription}${var.aks_purpose_short}${var.environment}${each.value.kv_name}${var.region_map_location[var.location]["location"]}kv" //app551camnpinfraengue2kv
  # var.keyvault_name != null ? var.keyvault_name : "${var.subscription}${each.value.kv_name}${var.environment}${var.region_map_location[var.location]["location"]}kv"
  // app551infraengnpue2kv
  location                      = var.location
  sku_name                      = var.sku_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  ip_rules                      = each.value.keyvault_ip_rules
  default_action                = each.value.default_action
  purge_protection_enabled      = each.value.purge_protection_enabled
  enable_rbac_authorization     = each.value.enable_rbac_authorization // default this
  rbac_access                   = each.value.rbac_access
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_ids    = []
  tags                          = can(each.value["tags"]) != false ? merge(var.tags, each.value["tags"]) : var.tags
}


resource "azurerm_role_assignment" "uami" {
  depends_on           = [module.kv]
  for_each             = var.enable_keyvault == true ? var.namespace : {}
  scope                = module.kv["kv1"].keyvault_id // fix each.key
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.um_identity[each.key].principal_id
}

resource "azurerm_role_assignment" "uami_reader" {
  depends_on           = [module.kv]
  for_each             = var.enable_keyvault == true ? var.namespace : {}
  scope                = module.kv["kv1"].keyvault_id // fix each.key
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.um_identity[each.key].principal_id
}


module "pe_keyvault" {
  source                       = "git@github.com:dayforcecloud/terraform-azurerm-private-endpoint.git//?ref=v1.0.7"
  for_each                     = var.enable_keyvault == true && var.enable_kv_private_endpoints == true ? var.keyvault : {}
  depends_on                   = [module.kv]
  location                     = var.location
  remote_resource_id           = module.kv[each.key].keyvault_id
  remote_resource_name         = module.kv[each.key].keyvault_name
  remote_resource_group_name   = module.rg[each.value.ns_key].resource_group_name
  subresource_names            = ["vault"]
  private_connection_subnet_id = local.backend_tier2_network.defaults.subnets_ids[1]
  private_dns_zone             = var.private_dns_zone
  private_dns_zone_name        = "privatelink.vaultcore.azure.net"
  private_dns_zone_group_name  = "default"
  tags                         = can(each.value["tags"]) != false ? merge(var.tags, each.value["tags"]) : var.tags
}


#-------------------------------------------------------------
# Create Metic Alerts - Key Vault
#-------------------------------------------------------------

locals {
  kv_metric_map = var.enable_keyvault && contains(local.sre_appd_env_dpy, var.environment) ? {
    for kv_key, kv_value in var.keyvault :
    kv_key => {
      metric_alerts = {
        "ma1" = {
          description = "Key Vault Availability Below 100 Percent"
          severity    = 1
          enabled     = true

          criteria = [
            {
              metric_namespace = "Microsoft.KeyVault/vaults"
              metric_name      = "Availability"
              aggregation      = "Average"
              operator         = "LessThan"
              threshold        = 100
            }
          ]
        }

        "ma2" = {
          description = "Key Vault Overall Service API Latency Above 1000 ms"
          severity    = 2
          enabled     = true

          criteria = [
            {
              metric_namespace = "Microsoft.KeyVault/vaults"
              metric_name      = "ServiceAPILatency"
              aggregation      = "Average"
              operator         = "GreaterThan"
              threshold        = 1000
            },
            {
              metric_namespace = "Microsoft.KeyVault/vaults"
              metric_name      = "ServiceApiHit"
              aggregation      = "Average"
              operator         = "GreaterThan"
              threshold        = 10
            }
          ]
        }


      }

    }
  } : null

  kv_metric_creations = var.enable_keyvault == true && contains(local.sre_appd_env_dpy, var.environment) ? flatten(
    [for kv_key, kv_value in var.keyvault :
      [for kv_met_key, kv_met_value in local.kv_metric_map[kv_key].metric_alerts :
        {
          name = "${module.kv[kv_key].keyvault_name}-${kv_met_value.description}"
          resource_group_name = can(kv_value["resource_group_name"]) != false ? kv_value["resource_group_name"] : (
            can(kv_value["ns_key"]) != false ? module.rg[kv_value["ns_key"]].resource_group_name : null
          )
          description              = "${module.kv[kv_key].keyvault_name}-${kv_met_value.description}"
          scopes                   = [module.kv[kv_key].keyvault_id]
          enabled                  = can(kv_met_value.enabled) != false ? kv_met_value.enabled : null
          auto_mitigate            = can(kv_met_value.auto_mitigate) != false ? kv_met_value.auto_mitigate : null
          severity                 = can(kv_met_value.severity) != false ? kv_met_value.severity : null
          frequency                = can(kv_met_value.frequency) != false ? kv_met_value.frequency : null
          window_size              = can(kv_met_value.window_size) != false ? kv_met_value.window_size : null
          target_resource_type     = can(kv_met_value.target_resource_type) != false ? kv_met_value.target_resource_type : null
          target_resource_location = can(kv_met_value.target_resource_location) != false ? kv_met_value.target_resource_location : null
          criteria                 = kv_met_value.criteria
          tags                     = can(kv_value["tags"]) != false ? merge(var.tags, kv_value["tags"]) : var.tags

          action = module.action_groups.action_groups["${local.ag_name}"].id != null && local.action_group_sre_id != null ? (
            [
              {
                action_group_id = module.action_groups.action_groups["${local.ag_name}"].id
              },
              {
                action_group_id = local.action_group_sre_id
              }
            ]
            ) : (
            module.action_groups.action_groups["${local.ag_name}"].id != null && local.action_group_sre_id == null ? (
              [
                {
                  action_group_id = module.action_groups.action_groups["${local.ag_name}"].id
                }
              ]
              ) : (
              module.action_groups.action_groups["${local.ag_name}"].id == null && local.action_group_sre_id != null ? (
                [
                  {
                    action_group_id = local.action_group_sre_id
                  }
                ]
              ) : module.action_groups.action_groups["${local.ag_name}"].id == null && local.action_group_sre_id == null ? [] : []
            )
          )
        }
      ]
    ]
  ) : null

  kv_metric_creations_nodes = var.enable_keyvault == true && contains(local.sre_appd_env_dpy, var.environment) ? { for name in local.kv_metric_creations : name.name => name } : null

}


module "kv_ma" {
  source        = "git@github.com:DayforceCloud/terraform-azurerm-alerting//modules/metric//?ref=v1.2.7"
  depends_on    = [module.rg, module.kv, module.action_groups]
  metric_alerts = var.enable_keyvault == true && contains(local.sre_appd_env_dpy, var.environment) ? local.kv_metric_creations_nodes : {}
}
