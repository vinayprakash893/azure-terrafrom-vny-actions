

#---------------------------------------------------------------------------
#  Keyvault Secrets App Insight
#---------------------------------------------------------------------------

locals {
  kv_secret_shared_appinsights = {
    "kv1" = {
      name  = "appinsights-shared-connection-name"
      value = local.backend_tier3_aks_cluster.defaults.app_insights_connection_strings_map["appinsight1"]
    }
  }
}

resource "azurerm_key_vault_secret" "appinsights_shared_connection_string" {
  depends_on   = [module.kv]
  for_each     = var.enable_keyvault == true ? local.kv_secret_shared_appinsights : {}
  name         = each.value["name"]
  value        = each.value["value"]
  key_vault_id = module.kv[each.key].keyvault_id
}



#---------------------------------------------------------------------------
#  Keyvault Secrets - Kafka Config
#---------------------------------------------------------------------------

locals {
  kafka_shared_secrets = {
    "kafka-shared-url-bootstrap"      = "dummyvalue"
    "kafka-shared-user-bootstrap"     = "dummyvalue"
    "kafka-shared-password-bootstrap" = "dummyvalue"
    "kafka-shared-url-registry"       = "dummyvalue"
    "kafka-shared-user-registry"      = "dummyvalue"
    "kafka-shared-password-registry"  = "dummyvalue"
  }
}

resource "azurerm_key_vault_secret" "kafka_shared_secrets" {
  for_each     = var.enable_kafka_secret == true ? local.kafka_shared_secrets : {}
  depends_on   = [module.kv]
  name         = each.key
  value        = each.value
  key_vault_id = module.kv["kv1"].keyvault_id

  lifecycle {
    ignore_changes = [value]
  }
}

#---------------------------------------------------------------------------
#  Keyvault Secrets - DFID Integration
#---------------------------------------------------------------------------

locals {
  dfid_shared_secrets = {
    "dfid-shared-url-name"      = "dummyvalue"
    "dfid-shared-client-id"     = "dummyvalue"
    "dfid-shared-client-secret" = "dummyvalue"
  }
}

resource "azurerm_key_vault_secret" "dfid_shared_secrets" {
  for_each     = var.enable_dfid_integration == true ? local.dfid_shared_secrets : {}
  depends_on   = [module.kv]
  name         = each.key
  value        = each.value
  key_vault_id = module.kv["kv1"].keyvault_id

  lifecycle {
    ignore_changes = [value]
  }
}

#---------------------------------------------------------------------------
#  Keyvault Secrets - Regional Database Support
#---------------------------------------------------------------------------

locals {
  sql_shared_secrets = {
    "sql-shared-server-name"    = "dummyvalue"
    "sql-shared-database-name"  = "dummyvalue"
    "sql-shared-login-admin"    = "dummyvalue"
    "sql-shared-password-admin" = "dummyvalue"
    "sql-shared-login-user"     = "dummyvalue"
    "sql-shared-password-user"  = "dummyvalue"
  }
}

resource "azurerm_key_vault_secret" "sql_shared_secrets" {
  for_each     = var.enable_regional_db == true ? local.sql_shared_secrets : {}
  depends_on   = [module.kv]
  name         = each.key
  value        = each.value
  key_vault_id = module.kv["kv1"].keyvault_id

  lifecycle {
    ignore_changes = [value]
  }
}


#---------------------------------------------------------------------------
#  Keyvault Secrets - client Database Support
#---------------------------------------------------------------------------

locals {
  sql_client_secrets = {
    "mobile-shared-url-service" = "dummyvalue"
    "sql-client-login-user"     = "dummyvalue"
    "sql-client-password-user"  = "dummyvalue"
    "sql-client-login-admin"    = "dummyvalue"
    "sql-client-password-admin" = "dummyvalue"
  }
}

resource "azurerm_key_vault_secret" "sql_client_secrets" {
  for_each     = var.enable_client_db == true ? local.sql_client_secrets : {}
  depends_on   = [module.kv]
  name         = each.key
  value        = each.value
  key_vault_id = module.kv["kv1"].keyvault_id

  lifecycle {
    ignore_changes = [value]
  }
}

#-------------------------------------------------------------
# Create Key Vault Secrets - Redis
#-------------------------------------------------------------


resource "azurerm_key_vault_secret" "primary_redis_client_connection_string" {
  for_each = var.enable_redis_cache == true ? var.redis_cache : {}
  depends_on = [
    module.redis_cache, module.kv
  ]
  name         = "redis-client-connectionstring-primary"
  value        = module.redis_cache[each.key].redis_cache_primary_connection_string
  key_vault_id = module.kv["kv1"].keyvault_id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "secondary_redis_client_connection_string" {
  for_each = var.enable_redis_cache == true ? var.redis_cache : {}
  depends_on = [
    module.redis_cache, module.kv
  ]

  name         = "redis-client-connectionstring-secondary"
  value        = module.redis_cache[each.key].redis_cache_secondary_connection_string
  key_vault_id = module.kv["kv1"].keyvault_id

  lifecycle {
    ignore_changes = [value]
  }
}

#---------------------------------------------------------------------------
#  Keyvault Secrets - Storage Accounts
#---------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "blob_client_connection_string" {
  for_each     = var.enable_storage_accounts == true ? var.storage_accounts : {}
  depends_on   = [module.sa, module.kv]
  name         = "blob-client-url-name"
  value        = module.sa[each.key].primary_blob_endpoints[0]
  key_vault_id = module.kv["kv1"].keyvault_id


  lifecycle {
    ignore_changes = [value]
  }
}
