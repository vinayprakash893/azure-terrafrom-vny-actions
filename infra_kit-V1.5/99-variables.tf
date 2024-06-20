variable "location" {
  description = "Region to deploy service(s) into"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name for application"
  type        = string
  default     = null
}

variable "subscription" {
  description = "Subscription where resource resides"
  type        = string
  default     = null
}

variable "purpose" {
  description = "Reason for building azure resource"
  type        = string
  default     = null
}

variable "aks_purpose_short" {
  description = "Purpose use for naming resources shortname"
  type        = string
  default     = "cam"
}

variable "aks_purpose" {
  description = "Purpose use for naming resources"
  type        = string
  default     = "camelot"
}

variable "team_name" {
  description = "Name of Teams resource"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags that are added to resource"
  type        = map(string)
  default     = {}
}

variable "private_dns_zone" {
  type        = string
  description = "(Required) Provate DNS zone name to build resource ID."
  default     = "/subscriptions/68a4597f-4bd5-4df8-b717-165bdb017332/resourceGroups/ss101-dns-pe-prod-eastus2/providers/Microsoft.Network/privateDnsZones"
}

variable "tier1_remote_state_rg" {
  description = "remote tfstate rg"
  type        = string
  default     = null
}

variable "tier1_remote_state_sa" {
  description = "remote tfstate storage account"
  type        = string
  default     = null
}

variable "tier1_remote_state_container" {
  description = "remote tfstate storage container"
  type        = string
  default     = null
}

variable "tier1_remote_state_key" {
  description = "remote tfstate storage key"
  type        = string
  default     = null
}

variable "tier1_remote_state_sub_id" {
  description = "remote tfstate subscription id"
  type        = string
  default     = null
}

variable "tier2_remote_state_rg" {
  description = "remote tfstate rg"
  type        = string
  default     = null
}

variable "tier2_remote_state_sa" {
  description = "remote tfstate storage account"
  type        = string
  default     = null
}

variable "tier2_remote_state_container" {
  description = "remote tfstate storage container"
  type        = string
  default     = null
}

variable "tier2_remote_state_key" {
  description = "remote tfstate storage key"
  type        = string
  default     = null
}

variable "tier2_remote_state_sub_id" {
  description = "remote tfstate subscription id"
  type        = string
  default     = null
}

variable "tfc_org" {
  type        = string
  description = "Terraform Cloud organization"
  default     = null
}

variable "tier2_tfc_workspace" {
  type        = string
  description = "Terraform Cloud workspace name for Tier 2"
  default     = null
}

variable "tier3_tfc_workspace" {
  type        = string
  description = "Terraform Cloud workspace name for Tier 3"
  default     = null
}

variable "tier1_tfc_workspace" {
  type        = string
  description = "Terraform Cloud workspace name for ak8s defaults"
  default     = null
}


variable "enable_tfc_remote_state" {
  type        = bool
  description = "Use Terraform Cloud Remote State"
  default     = false
}


variable "namespace" {
  description = "Name of Namespace"
  default     = {}
  type        = map(any)
}

variable "tier3_remote_state_rg" {
  description = "remote tfstate rg"
  type        = string
  default     = null
}

variable "tier3_remote_state_sa" {
  description = "remote tfstate storage account"
  type        = string
  default     = null
}

variable "tier3_remote_state_container" {
  description = "remote tfstate storage container"
  type        = string
  default     = null
}

variable "tier3_remote_state_key" {
  description = "remote tfstate storage key"
  type        = string
  default     = null
}

variable "tier3_remote_state_sub_id" {
  description = "remote tfstate subscription id"
  type        = string
  default     = null
}

variable "sku_name" {
  description = "Keyvault sku"
  default     = "premium"
  type        = string
}

variable "keyvault_name" {
  description = "Manually entered Key Vault Name"
  type        = string
  default     = null
}

variable "keyvault" {
  default = {}
}


variable "enable_kv_private_endpoints" {
  type        = bool
  description = "Enable PE for keyvault"
  default     = false
}

variable "enable_keyvault" {
  type        = bool
  description = "Enable Keyvault"
  default     = false
}


variable "enable_storage_accounts" {
  type        = bool
  description = "Enable Storage Accounts"
  default     = false
}

variable "enable_redis_cache" {
  type        = bool
  description = "Enable Redis Cache"
  default     = false
}

variable "region_map_location" {
  description = ""
  type = map(object({
    location = string

  }))
  default = {
    eastus2 = {
      location = "ue2"
    },
    centralus = {
      location = "uc"
    },
    westeurope = {
      location = "euw"
    },
    northeurope = {
      location = "eun"
    },
    canadacentral = {
      location = "cac"
    },
    canadaeast = {
      location = "cae"
    },
    southeastasia = {
      location = "ase"
    },
    australiaeast = {
      location = "aue"
    },
    australiasoutheast = {
      location = "ause"
    },
  }
}


variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this Key Vault. Defaults to true."
  type        = bool
  default     = true
}

variable "redis_public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this redis. Defaults to true."
  type        = bool
  default     = false
}

variable "storage_accounts" {
  description = "Map of storage accounts"
  /* type = map(object({
    name                             = string
    sku                              = string
    account_kind                     = optional(string, "StorageV2")
    access_tier                      = optional(string)
    assign_identity                  = optional(string)
    cmk_enabled                      = optional(bool)
    ns_key                           = optional(string)
    cross_tenant_replication_enabled = optional(bool)
    account_replication_type         = optional(string, "LRS")
    shared_access_key_enabled        = optional(bool)
    network_rules = object({
      bypass                     = list(string)
      default_action             = string
      ip_rules                   = list(string)
      virtual_network_subnet_ids = optional(list(string))
    })

    min_tls_version                 = optional(string)
    enable_large_file_share         = optional(bool)
    enable_https_traffic_only       = optional(bool)
    is_hns_enabled                  = optional(bool)
    blob_delete_retention_days      = optional(number, 7)
    container_delete_retention_days = optional(number, 7)
    change_feed_enabled             = optional(bool)
    blob_versioning_enabled         = optional(bool)
    infra_encryption_enabled        = optional(bool)
    allow_nested_items_to_be_public = optional(bool)
    smb = object({
      versions                        = list(string)
      authentication_types            = list(string)
      kerberos_ticket_encryption_type = list(string)
      channel_encryption_type         = list(string)
    })
    management_policy_rules = map(object({
      name    = string
      enabled = bool
      filters = map(object({
        prefix_match = list(string)
        blob_types   = list(string)
      }))
      actions = object({
        snapshot = map(object({
          delete_after_days_since_creation_greater_than    = number
          change_tier_to_archive_after_days_since_creation = number
          change_tier_to_cool_after_days_since_creation    = number
        }))
        base_blob = map(object({
          tier_to_cool_after_days_since_modification_greater_than    = number
          tier_to_archive_after_days_since_modification_greater_than = number
          delete_after_days_since_modification_greater_than          = number
        }))
        version = map(object({
          change_tier_to_archive_after_days_since_creation = number
          change_tier_to_cool_after_days_since_creation    = number
          delete_after_days_since_creation                 = number
        }))
      })
    }))
  })) */
  default = {}
}



variable "file_shares" {
  description = "Map of file shares"
  default     = {}
}

variable "queues" {
  description = "Map of queues"
  default     = {}
}

variable "tables" {
  description = "Map of tables"
  default     = {}
}

variable "blobs" {
  description = "Map of blobs"
  default     = {}
}

variable "containers" {
  description = "Map of Storage Containers for storage account"
  default     = {}
}

variable "data_persistence_enabled" {
  description = "Enable or disbale Redis Database Backup. Only supported on Premium SKU's"
  type        = bool
  default     = true
}

variable "data_persistence_backup_frequency" {
  description = "The Backup Frequency in Minutes. Only supported on Premium SKU's. Possible values are: `15`, `30`, `60`, `360`, `720` and `1440`"
  default     = 60
  type        = number
}

variable "data_persistence_backup_max_snapshot_count" {
  description = "The maximum number of snapshots to create as a backup. Only supported for Premium SKU's"
  default     = 1
  type        = number
}

variable "redis_subnet_id_number" {
  description = "(optional) The subnet id number / index used with cache_subnet_id in redis for data reference lookup."
  type        = number
  default     = 4
}

variable "enable_non_ssl_port" {
  description = "Enable the non-SSL port (6379) - disabled by default."
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "The minimum TLS version. Possible values are 1.0, 1.1 and 1.2. Defaults to 1.0."
  type        = string
  default     = "1.2"
}

variable "assign_identity" {
  description = ""
  type        = string
  default     = "UserAssigned"
}

variable "redis_cache" {
  description = "Map of Redis Cache which needs to be created in a resource group"
  /* type = object({
    name                          = optional(string)
    sku_name                      = optional(string, "Premium")
    enable_non_ssl_port           = optional(bool, false)
    minimum_tls_version           = optional(string, "1.2")
    redis_version                 = optional(number, 4)
    cluster_shard_count           = optional(number, 2)
    capacity                      = optional(number, 2)
    private_static_ip_address     = optional(string)
    zones                         = optional(list(number))
    replicas_per_master           = optional(number)
    replicas_per_primary          = optional(number)
    public_network_access_enabled = optional(bool, false) */

  //assign_identity               = optional(string)

  /* redis_configuration = optional(object({
      enable_authentication           = optional(bool, true)
      maxmemory_reserved              = optional(number)
      maxmemory_delta                 = optional(number)
      maxmemory_policy                = optional(string)
      maxfragmentationmemory_reserved = optional(number)
      notify_keyspace_events          = optional(string)
    })) */

  /* patch_schedule = optional(list(object({
      day_of_week        = optional(string)
      start_hour_utc     = optional(number)
      maintenance_window = optional(string, "PT5H")
    }))) */

  /* redis_firewall_rules = optional(list(object({
      name     = optional(string)
      start_ip = optional(string)
      end_ip   = optional(string)
    }))) */

  //})

}


/* variable "patch_schedule" {

} */

variable "enable_sa_blob_private_endpoints" {
  type        = bool
  description = "Enable PE for Storage Accounts"
  default     = true
}

variable "enable_redis_private_endpoints" {
  type        = bool
  description = "Enable PE for Redis Cache"
  default     = false
}

/* variable "redis_configuration" {
  type = object({
    redis_configuration = optional(object({
      enable_authentication           = optional(bool, true)
      maxmemory_reserved              = optional(number)
      maxmemory_delta                 = optional(number)
      maxmemory_policy                = optional(string)
      maxfragmentationmemory_reserved = optional(number)
      notify_keyspace_events          = optional(string)
    }))  */

/* patch_schedule = optional(list(object({
      day_of_week        = optional(string)
      start_hour_utc     = optional(number)
      maintenance_window = optional(string, "PT5H")
    }))) */

/* redis_firewall_rules = optional(list(object({
      name     = optional(string)
      start_ip = optional(string)
      end_ip   = optional(string)
    }))) */

/* })

  description = "Map of Redis Cache which needs to be created in a resource group"
}  */


variable "key_vault_key_id" {
  description = "KeyVault Key ID used for Customer Managed Key encryption."
  type        = string
  default     = null
}

variable "cmk_identity_id" {
  description = "Identity ID used when using Customer Managed Keys"
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "List of Managed Identities"
  type        = list(string)
  default     = null
}

variable "team_aad_group" {
  description = " This should use an azure objectId of the AD group that will have permissions to administer the AKS cluster."
  type        = string
}

variable "enable_kafka_secret" {
  type        = bool
  description = "Enable Kafka Secret"
  default     = false
}

variable "action_group_enabled" {
  type        = bool
  description = "Enable or disable team action group."
  default     = true
}

variable "action_group_webhooks" {
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
    use_aad_auth            = optional(bool, false)
    aad_auth = optional(object({
      object_id      = string
      identifier_uri = string
      tenant_id      = optional(string)
    }))
  }))
  default = []
}

variable "action_group_emails" {
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = []
}


variable "enable_dfid_integration" {
  type        = bool
  description = "Enable DFID Integration"
  default     = false
}

variable "enable_regional_db" {
  type        = bool
  description = "Enable Regional DB Support"
  default     = false
}

variable "enable_client_db" {
  type        = bool
  description = "Enable Client DB Support"
  default     = false
}
