

#---------------------------------------------------------------------------
#  Keyvault Secrets App Insight
#---------------------------------------------------------------------------

locals {
  kv_secret_appinsights = {
    "kv1" = {
      name  = "appinsights-connection"
      value = local.backend_tier3_aks_cluster.defaults.app_insights_connection_strings_map["appinsight1"]
    }
  }
}

resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  depends_on   = [module.kv]
  for_each     = var.enable_keyvault == true ? local.kv_secret_appinsights : {}
  name         = each.value["name"]
  value        = each.value["value"]
  key_vault_id = module.kv[each.key].keyvault_id
}



#---------------------------------------------------------------------------
#  Keyvault Secrets - Kafka Config
#---------------------------------------------------------------------------

locals {
  kafka_secrets = {
    "kafka-bootstrap-url"      = "dummyvalue"
    "kafka-bootstrap-user"     = "dummyvalue"
    "kafka-bootstrap-password" = "dummyvalue"
    "kafka-registry-url"       = "dummyvalue"
    "kafka-registry-user"      = "dummyvalue"
    "kafka-registry-password"  = "dummyvalue"
  }
}

resource "azurerm_key_vault_secret" "kafka_bootstrap_url" {
  for_each     = var.enable_kafka_secret == true ? local.kafka_secrets : {}
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
  dfid_secrets = {
    "dfid-default-url"          = "dummyvalue"
    "dfid-default-clientid"     = "dummyvalue"
    "dfid-default-clientsecret" = "dummyvalue"
  }
}

resource "azurerm_key_vault_secret" "dfid_secrets" {
  for_each     = var.enable_dfid_integration == true ? local.dfid_secrets : {}
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
  regional_db_support_secrets = {
    "regional-db-server"         = "dummyvalue"
    "regional-db-database"       = "dummyvalue"
    "regional-db-admin-login"    = "dummyvalue"
    "regional-db-admin-password" = "dummyvalue"
    "regional-db-user-login"     = "dummyvalue"
    "regional-db-user-password"  = "dummyvalue"
  }
}

resource "azurerm_key_vault_secret" "regional_db_support_secrets" {
  for_each     = var.enable_regional_db == true ? local.regional_db_support_secrets : {}
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
  client_db_support_secrets = {
    "mobile-service-url"       = "dummyvalue"
    "client-db-user-login"     = "dummyvalue"
    "client-db-user-password"  = "dummyvalue"
    "client-db-admin-login"    = "dummyvalue"
    "client-db-admin-password" = "dummyvalue"
  }
}

resource "azurerm_key_vault_secret" "client_db_support_secrets" {
  for_each     = var.enable_client_db == true ? local.client_db_support_secrets : {}
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


resource "azurerm_key_vault_secret" "primary_connection_string" {
  for_each = var.enable_redis_cache == true ? var.redis_cache : {}
  depends_on = [
    module.redis_cache, module.kv
  ]
  name         = "redis-connection-string-primary"
  value        = module.redis_cache[each.key].redis_cache_primary_connection_string
  key_vault_id = module.kv["kv1"].keyvault_id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "secondary_connection_string" {
  for_each = var.enable_redis_cache == true ? var.redis_cache : {}
  depends_on = [
    module.redis_cache, module.kv
  ]

  name         = "redis-connection-string-secondary"
  value        = module.redis_cache[each.key].redis_cache_secondary_connection_string
  key_vault_id = module.kv["kv1"].keyvault_id

  lifecycle {
    ignore_changes = [value]
  }
}

#---------------------------------------------------------------------------
#  Keyvault Secrets - Storage Accounts
#---------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "storage_account_connection_string" {
  for_each     = var.enable_storage_accounts == true ? var.storage_accounts : {}
  depends_on   = [module.sa, module.kv]
  name         = "blob-storage-url"
  value        = module.sa[each.key].primary_blob_endpoints[0]
  key_vault_id = module.kv["kv1"].keyvault_id


  lifecycle {
    ignore_changes = [value]
  }
}
