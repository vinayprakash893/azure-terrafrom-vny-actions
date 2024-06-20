#---------------------------------------------------------------------------
#  Managed Identity for Redis Cache
#---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "redis_managed_identity" {
  for_each            = var.enable_redis_cache == true ? var.redis_cache : {} //var.enable_redis_identity == true ?  toset(["redis_managed_identity"]) : toset([]) // { "redis_managed_identity" = {} } : {}
  name                = "${var.subscription}-${var.aks_purpose_short}-${var.environment}-${var.team_name}-redis-identity-${var.location}"
  resource_group_name = module.rg[each.value.ns_key].resource_group_name //  module.rg["ns1"].resource_group_name
  location            = var.location
  tags                = var.tags
}


# -------------------------------------------------------------
# Redis Cache
# -------------------------------------------------------------

module "redis_cache" {
  source               = "git@github.com:dayforcecloud/terraform-azurerm-redis-cache.git//?ref=v1.2.3"
  for_each             = var.enable_redis_cache == true ? var.redis_cache : {}
  name                 = each.value.name // "${var.subscription}-${var.purpose}-${var.environment}-${var.location}"
  resource_group_name  = module.rg[each.value.ns_key].resource_group_name
  location             = var.location
  storage_account_name = "${var.subscription}${var.environment}${var.team_name}redis" // ceridian standards
  //${var.subscription}${var.team_name}${var.environment}${var.region_map_location[var.location]["location"]}redis
  data_persistence_enabled                   = var.data_persistence_enabled
  data_persistence_backup_frequency          = var.data_persistence_backup_frequency
  data_persistence_backup_max_snapshot_count = var.data_persistence_backup_max_snapshot_count
  sku_name                                   = each.value.sku_name
  enable_non_ssl_port                        = var.enable_non_ssl_port
  minimum_tls_version                        = var.minimum_tls_version
  redis_version                              = each.value.redis_version
  cluster_shard_count                        = each.value.cluster_shard_count
  capacity                                   = each.value.capacity
  public_network_access_enabled              = var.redis_public_network_access_enabled
  cache_subnet_id = can(local.backend_tier2_network.defaults.subnets_ids[var.redis_subnet_id_number]) ? (
    local.backend_tier2_network.defaults.subnets_ids[var.redis_subnet_id_number]
  ) : null // need to add paas subnet
  assign_identity      = var.assign_identity
  identity_ids         = [azurerm_user_assigned_identity.redis_managed_identity[each.key].id]
  patch_schedule       = each.value.patch_schedule
  redis_firewall_rules = each.value.redis_firewall_rules
  redis_configuration  = each.value.redis_configuration
  tags                 = var.tags
}

#-------------------------------------------------------------
# Create Private Endpoints
#-------------------------------------------------------------

module "pe_cache_redis" {
  source                       = "git@github.com:dayforcecloud/terraform-azurerm-private-endpoint//?ref=v1.0.8"
  for_each                     = var.enable_redis_private_endpoints == true && var.enable_redis_cache == true ? var.redis_cache : {}
  depends_on                   = [module.redis_cache]
  location                     = var.location
  remote_resource_id           = module.redis_cache[each.key].id
  remote_resource_name         = module.redis_cache[each.key].hostname
  remote_resource_group_name   = module.rg[each.value.ns_key].resource_group_name
  subresource_names            = ["redisCache"]
  private_connection_subnet_id = local.backend_tier2_network.defaults.subnets_ids[1]
  private_dns_zone             = var.private_dns_zone
  private_dns_zone_name        = "privatelink.redis.cache.windows.net"
  private_dns_zone_group_name  = "default"
  tags                         = var.tags
}

#-------------------------------------------------------------
# Create Metic Alerts - Redis
#-------------------------------------------------------------

locals {
  redis_metric_map = var.enable_redis_cache && contains(local.sre_appd_env_dpy, var.environment) ? {
    for redis_key, redis_value in var.redis_cache :
    redis_key => {
      metric_alerts = {
        "ma1" = {
          description = "Redis CPU Above 85 Percent"
          severity    = 2
          enabled     = true

          criteria = [
            {
              metric_namespace = "Microsoft.Cache/Redis"
              metric_name      = "percentProcessorTime"
              aggregation      = "Average"
              operator         = "GreaterThan"
              threshold        = 85
            }
          ]
        }

        "ma2" = {
          description = "Redis Memory Above 80 Percent"
          severity    = 2
          enabled     = true

          criteria = [
            {
              metric_namespace = "Microsoft.Cache/Redis"
              metric_name      = "usedmemorypercentage"
              aggregation      = "Average"
              operator         = "GreaterThan"
              threshold        = 80
            }
          ]
        }

        "ma3" = {
          description = "Redis Errors Detected"
          severity    = 2
          enabled     = true

          criteria = [
            {
              metric_namespace = "Microsoft.Cache/Redis"
              metric_name      = "errors"
              aggregation      = "Total"
              operator         = "GreaterThan"
              threshold        = 10
            }
          ]
        }

        "ma4" = {
          description = "Connected Clients over 90 Percent of available limit"
          severity    = 2
          enabled     = true

          criteria = [
            {
              metric_namespace = "Microsoft.Cache/Redis"
              metric_name      = "usedmemorypercentage"
              aggregation      = "Maximum"
              operator         = "GreaterThan"
              threshold        = module.redis_cache[redis_key].maxclients * 0.9
            }
          ]
        }

      }

    }
  } : null

  redis_metric_creations = var.enable_redis_cache == true && contains(local.sre_appd_env_dpy, var.environment) ? flatten(
    [for redis_key, redis_value in var.redis_cache :
      [for redis_met_key, redis_met_value in local.redis_metric_map[redis_key].metric_alerts :
        {
          name                     = "${redis_value.name}-${redis_met_value.description}"
          resource_group_name      = module.rg[redis_value.ns_key].resource_group_name
          description              = "${redis_value.name}-${redis_met_value.description}"
          scopes                   = [module.redis_cache[redis_key].id]
          enabled                  = can(redis_met_value.enabled) != false ? redis_met_value.enabled : null
          auto_mitigate            = can(redis_met_value.auto_mitigate) != false ? redis_met_value.auto_mitigate : null
          severity                 = can(redis_met_value.severity) != false ? redis_met_value.severity : null
          frequency                = can(redis_met_value.frequency) != false ? redis_met_value.frequency : null
          window_size              = can(redis_met_value.window_size) != false ? redis_met_value.window_size : null
          target_resource_type     = can(redis_met_value.target_resource_type) != false ? redis_met_value.target_resource_type : null
          target_resource_location = can(redis_met_value.target_resource_location) != false ? redis_met_value.target_resource_location : null
          criteria                 = redis_met_value.criteria
          tags                     = var.tags

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

  redis_metric_creations_nodes = var.enable_redis_cache == true && contains(local.sre_appd_env_dpy, var.environment) ? { for name in local.redis_metric_creations : name.name => name } : null

}

module "redis_ma" {
  source        = "git@github.com:DayforceCloud/terraform-azurerm-alerting//modules/metric//?ref=v1.2.7"
  depends_on    = [module.rg, module.redis_cache, module.action_groups]
  metric_alerts = var.enable_redis_cache == true && contains(local.sre_appd_env_dpy, var.environment) ? local.redis_metric_creations_nodes : {}
}
