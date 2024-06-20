#-------------------------------------------------------------
# Create Storage Account
#-------------------------------------------------------------

module "sa" {
  source              = "git@github.com:dayforcecloud/terraform-azurerm-storage-account.git//?ref=v1.1.11"
  for_each            = var.enable_storage_accounts == true ? var.storage_accounts : {}
  storage_accounts    = var.storage_accounts
  resource_group_name = module.rg[each.value.ns_key].resource_group_name
  location            = var.location
  containers          = var.containers
  key_vault_key_id    = var.key_vault_key_id
  cmk_identity_id     = var.cmk_identity_id
  identity_ids        = var.identity_ids
  file_shares         = var.file_shares
  queues              = var.queues
  tables              = var.tables
  blobs               = var.blobs
  tags                = can(each.value["tags"]) != false ? merge(var.tags, each.value["tags"]) : var.tags
}

#-------------------------------------------------------------
# Create Role Assignments
#-------------------------------------------------------------

resource "azurerm_role_assignment" "uami_sa" {
  depends_on           = [module.sa, azurerm_user_assigned_identity.um_identity]
  for_each             = var.enable_storage_accounts == true ? var.storage_accounts : {}
  scope                = module.sa[each.key].sa_key_output_map[each.key].id #module.sa["sa1"].keyvault_id // fix each.key
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.um_identity[each.value.ns_key].principal_id
}

resource "azurerm_role_assignment" "uami_reader_sa" {
  depends_on           = [module.sa, azurerm_user_assigned_identity.um_identity]
  for_each             = var.enable_storage_accounts == true ? var.storage_accounts : {}
  scope                = module.sa[each.key].sa_key_output_map[each.key].id #module.sa["sa1"].keyvault_id // fix each.key
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.um_identity[each.value.ns_key].principal_id
}

#-------------------------------------------------------------
# Create Blob Storage PE
#-------------------------------------------------------------

module "pe_blob_storage" {
  source   = "git@github.com:dayforcecloud/terraform-azurerm-private-endpoint.git//?ref=v1.0.8"
  for_each = var.enable_sa_blob_private_endpoints == true && var.enable_storage_accounts == true ? var.storage_accounts : {}

  depends_on                   = [module.sa]
  location                     = var.location
  remote_resource_id           = module.sa[each.key].sa_key_output_map[each.key].id
  remote_resource_name         = module.sa[each.key].sa_key_output_map[each.key].name
  remote_resource_group_name   = module.rg[each.value.ns_key].resource_group_name
  subresource_names            = ["blob"]
  private_connection_subnet_id = local.backend_tier2_network.defaults.subnets_ids[1]
  private_dns_zone             = var.private_dns_zone
  private_dns_zone_name        = "privatelink.blob.core.windows.net"
  private_dns_zone_group_name  = "default"
  tags                         = can(each.value["tags"]) != false ? merge(var.tags, each.value["tags"]) : var.tags
}


#-------------------------------------------------------------
# Create Metic Alerts - Storage Account
#-------------------------------------------------------------

locals {
  sa_metric_map = var.enable_storage_accounts && contains(local.sre_appd_env_dpy, var.environment) ? {
    for sa_key, sa_value in var.storage_accounts :
    sa_key => {
      metric_alerts = {
        "ma1" = {
          description = "Storage Account Availability Below 80 Percent"
          severity    = 1
          enabled     = true

          criteria = [
            {
              metric_namespace = "Microsoft.Storage/storageAccounts"
              metric_name      = "Availability"
              aggregation      = "Average"
              operator         = "LessThan"
              threshold        = 80
            }
          ]
        }
      }
    }
  } : null

  sa_metric_creations = var.enable_storage_accounts == true && contains(local.sre_appd_env_dpy, var.environment) ? flatten(
    [for sa_key, sa_value in var.storage_accounts :
      [for sa_met_key, sa_met_value in local.sa_metric_map[sa_key].metric_alerts :
        {
          name = "${module.sa[sa_key].sa_key_output_map[sa_key].name}-${sa_met_value.description}"
          resource_group_name = can(sa_value["resource_group_name"]) != false ? sa_value["resource_group_name"] : (
            can(sa_value["ns_key"]) != false ? module.rg[sa_value["ns_key"]].resource_group_name : null
          )
          description              = "${module.sa[sa_key].sa_key_output_map[sa_key].name}-${sa_met_value.description}"
          scopes                   = [module.sa[sa_key].sa_key_output_map[sa_key].id]
          enabled                  = can(sa_met_value.enabled) != false ? sa_met_value.enabled : null
          auto_mitigate            = can(sa_met_value.auto_mitigate) != false ? sa_met_value.auto_mitigate : null
          severity                 = can(sa_met_value.severity) != false ? sa_met_value.severity : null
          frequency                = can(sa_met_value.frequency) != false ? sa_met_value.frequency : null
          window_size              = can(sa_met_value.window_size) != false ? sa_met_value.window_size : null
          target_resource_type     = can(sa_met_value.target_resource_type) != false ? sa_met_value.target_resource_type : null
          target_resource_location = can(sa_met_value.target_resource_location) != false ? sa_met_value.target_resource_location : null
          criteria                 = sa_met_value.criteria
          tags                     = can(sa_value["tags"]) != false ? merge(var.tags, sa_value["tags"]) : var.tags

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

  sa_metric_creations_nodes = var.enable_storage_accounts == true && contains(local.sre_appd_env_dpy, var.environment) ? { for name in local.sa_metric_creations : name.name => name } : null

}


module "sa_ma" {
  source        = "git@github.com:DayforceCloud/terraform-azurerm-alerting//modules/metric//?ref=v1.2.7"
  depends_on    = [module.rg, module.sa, module.action_groups]
  metric_alerts = var.enable_storage_accounts == true && contains(local.sre_appd_env_dpy, var.environment) ? local.sa_metric_creations_nodes : {}
}
