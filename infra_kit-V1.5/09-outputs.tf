#-------------------------------------------------------------
# Outputs
#-------------------------------------------------------------

output "resource_group" {
  value = [for x in module.rg : x.resource_group_name]
}

output "resource_group_id" {
  value = [for x in module.rg : x.resource_group_id]
}

output "kv_name" {
  value = var.enable_keyvault == true ? [for x in module.kv : x.keyvault_name] : null
}

output "kv_uri" {
  value = var.enable_keyvault == true ? [for x in module.kv : x.keyvault_uri] : null
}

output "kv_map" {
  value = var.enable_keyvault == true ? { for kv in keys(var.keyvault) : kv => module.kv[kv].keyvault_output } : null
}

output "infra_output" {
  value = {
    aks_cluster_admin_ad_groups = var.team_aad_group
    feature_team                = lookup(var.tags, "FeatureTeam", null)
    product_domain              = lookup(var.tags, "ProductDomain", null)
    sub_environment_name        = lookup(var.tags, "SubEnvironmentName", null)
    feature_id                  = var.team_name
    environment_name            = lookup(var.tags, "EnvironmentName", null)
    ha_cluster                  = lookup(var.tags, "HaCluster", null)
    aks_cluster_name            = element(local.backend_tier3_aks_cluster.defaults.kubernetes_cluster_name, 0)
    aks_cluster_rg              = element(local.backend_tier3_aks_cluster.defaults.resource_group_name, 0)
    # aks_public_ip_address = element(local.backend_tier3_aks_cluster.defaults.public_ip_address, 0)
    cluster_umi_name              = "${element(local.backend_tier3_aks_cluster.defaults.kubernetes_cluster_name, 0)}-agentpool"
    cluster_umi_client_id         = element(local.backend_tier3_aks_cluster.defaults.aks_user_assigned_identity, 0)
    secret_provider_keyvault_name = element([for x in module.kv : x.keyvault_name], 0)
    keyvaultname                  = join(", ", [for x in module.kv : x.keyvault_name])
    rgname                        = join(", ", [for x in module.rg : x.resource_group_name])
    namespace                     = join(", ", [for x in var.namespace : x.name])
    service_account_name          = join(", ", [for x in var.namespace : x.name])
    subscription_id               = data.azurerm_client_config.current.subscription_id
    tenant_id                     = data.azurerm_client_config.current.tenant_id
    app_umi_name                  = join(", ", [for x in azurerm_user_assigned_identity.um_identity : x.name])
    app_umi_client_id             = join(", ", [for x in azurerm_user_assigned_identity.um_identity : x.client_id])
    app_umi_object_id             = join(", ", [for x in azurerm_user_assigned_identity.um_identity : x.principal_id])

    keyvault_appinsights_keys     = var.enable_keyvault == true ? [for x in azurerm_key_vault_secret.appinsights_connection_string : x.name] : []
    keyvault_kafka_keys           = var.enable_kafka_secret == true ? [for x in azurerm_key_vault_secret.kafka_bootstrap_url : x.name] : []
    keyvault_dfid_keys            = var.enable_dfid_integration == true ? [for x in azurerm_key_vault_secret.dfid_secrets : x.name] : []
    keyvault_regional_db_keys     = var.enable_regional_db == true ? [for x in azurerm_key_vault_secret.regional_db_support_secrets : x.name] : []
    keyvault_client_db_keys       = var.enable_client_db == true ? [for x in azurerm_key_vault_secret.client_db_support_secrets : x.name] : []
    keyvault_redis_keys           = var.enable_redis_cache == true ? concat([for x in azurerm_key_vault_secret.primary_connection_string : x.name], [for x in azurerm_key_vault_secret.secondary_connection_string : x.name]) : []
    keyvault_storage_account_keys = var.enable_storage_accounts == true ? [for x in azurerm_key_vault_secret.storage_account_connection_string : x.name] : []

    keyvault_appinsights_shared_keys = var.enable_keyvault == true ? [for x in azurerm_key_vault_secret.appinsights_shared_connection_string : x.name] : []
    keyvault_kafka_shared_keys       = var.enable_kafka_secret == true ? [for x in azurerm_key_vault_secret.kafka_shared_secrets : x.name] : []
    keyvault_dfid_shared_keys        = var.enable_dfid_integration == true ? [for x in azurerm_key_vault_secret.dfid_shared_secrets : x.name] : []
    keyvault_sql_shared_keys         = var.enable_regional_db == true ? [for x in azurerm_key_vault_secret.sql_shared_secrets : x.name] : []
    keyvault_sql_client_keys         = var.enable_client_db == true ? [for x in azurerm_key_vault_secret.sql_client_secrets : x.name] : []
    keyvault_redis_client_keys       = var.enable_redis_cache == true ? concat([for x in azurerm_key_vault_secret.primary_redis_client_connection_string : x.name], [for x in azurerm_key_vault_secret.secondary_redis_client_connection_string : x.name]) : []
    keyvault_blob_client_keys        = var.enable_storage_accounts == true ? [for x in azurerm_key_vault_secret.blob_client_connection_string : x.name] : []
  }
}
