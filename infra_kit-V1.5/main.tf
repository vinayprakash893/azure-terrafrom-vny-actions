
# -------------------------------------------------------------
# Camelot Infra Kit
# -------------------------------------------------------------

module "infra_kit" {
  source = "git@github.com:dayforcecloud//terraform-azurerm-infrakit.git//?ref=dev"

  #----------------------------------------------------------------------------------------------------
  # Locals and providers
  #----------------------------------------------------------------------------------------------------

  subscription                     = local.subscription
  location                         = local.location
  environment                      = local.environment
  purpose                          = local.aks_cluster
  team_name                        = local.application_shortname
  tags                             = local.tags
  enable_dfid_integration          = local.enable_dfid_integration
  enable_regional_db               = local.enable_regional_db
  enable_client_db                 = local.enable_client_db
  enable_kafka_secret              = local.enable_kafka_secret
  enable_keyvault                  = true
  enable_storage_accounts          = local.enable_storage_accounts
  enable_redis_cache               = local.enable_redis_cache
  enable_kv_private_endpoints      = true
  enable_sa_blob_private_endpoints = local.enable_sa_blob_private_endpoints
  enable_redis_private_endpoints   = local.enable_redis_private_endpoints
  namespace                        = local.namespace
  keyvault                         = local.keyvault
  redis_cache                      = local.redis_cache
  storage_accounts                 = local.storage_accounts
  key_vault_key_id                 = local.key_vault_key_id
  cmk_identity_id                  = local.cmk_identity_id
  identity_ids                     = local.identity_ids
  team_aad_group                   = local.team_aad_group
  enable_tfc_remote_state          = local.enable_tfc_remote_state 
  tfc_org                          = local.tfc_org 
  tier1_tfc_workspace              = local.tier1_camelot_defaults_tfc_workspace 
  tier2_tfc_workspace              = local.tier2_tfc_workspace 
  tier3_tfc_workspace              = local.tier3_tfc_workspace
}

#-------------------------------------------------------------
# Data References
#-------------------------------------------------------------

data "azurerm_client_config" "current" {}

#-------------------------------------------------------------
# Required Providers
#-------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


#-----------------------------------------------------------------------
#  Variables
#-----------------------------------------------------------------------

variable "region_map" {
  description = ""
  type = map(object({
    location_name = string
  }))
  default = {
    eastus2 = {
      location_name = "ue2"
    },
    centralus = {
      location_name = "uc"
    },
    westeurope = {
      location_name = "euw"
    },
    northeurope = {
      location_name = "eun"
    },
    canadacentral = {
      location_name = "cac"
    },
    canadaeast = {
      location_name = "cae"
    },
    australiaeast = {
      location_name = "aue"
    },
    australiasoutheast = {
      location_name = "ase"
    },
  }
}

variable "env_type_map" {
  description = ""
  type = map(object({
    location_name = string
  }))
  default = {
    "Non Production" = {
      env_type = "np"
    },
    "Pre Production" = {
      env_type = "pre"
    },
    Production = {
      env_type = "prod"
    }
  }
}

variable "redis_map" {
  description = "Map for t-shirt size redis instances"
  type = map(object({
    sku_name            = optional(string)
    redis_version       = optional(number)
    cluster_shard_count = optional(number)
    capacity            = optional(number)
    redis_configuration = object({
      maxmemory_reserved = number
      maxmemory_delta    = number
      maxmemory_policy   = string
    })
    patch_schedule = list(object({
      day_of_week        = string
      start_hour_utc     = number
      maintenance_window = string
    }))
    redis_firewall_rules = list(object({
      name     = string
      start_ip = string
      end_ip   = string
    }))
  }))
  default = {
    np_small = {
      sku_name            = "Standard"
      redis_version       = 6
      cluster_shard_count = 2
      capacity            = 2
      redis_configuration = {
        maxmemory_reserved              = 299
        maxmemory_delta                 = 299
        maxfragmentationmemory_reserved = 299
        maxmemory_policy                = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"

        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
    np_medium = {
      sku_name            = "Standard"
      redis_version       = 6
      cluster_shard_count = 2
      capacity            = 4
      redis_configuration = {
        maxmemory_reserved              = 1330
        maxmemory_delta                 = 1330
        maxfragmentationmemory_reserved = 1330
        maxmemory_policy                = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"

        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
    np_large = {
      sku_name            = "Standard"
      redis_version       = 6
      cluster_shard_count = 4
      capacity            = 5
      redis_configuration = {
        maxmemory_reserved              = 2704
        maxmemory_delta                 = 2704
        maxfragmentationmemory_reserved = 2704
        maxmemory_policy                = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
    pre_small = {
      sku_name            = "Standard"
      redis_version       = 6
      cluster_shard_count = 2
      capacity            = 2
      redis_configuration = {
        maxmemory_reserved              = 299
        maxmemory_delta                 = 299
        maxfragmentationmemory_reserved = 299
        maxmemory_policy                = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"

        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
    pre_medium = {
      sku_name            = "Standard"
      redis_version       = 6
      cluster_shard_count = 2
      capacity            = 4
      redis_configuration = {
        maxmemory_reserved              = 1330
        maxmemory_delta                 = 1330
        maxfragmentationmemory_reserved = 1330
        maxmemory_policy                = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"

        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
    pre_large = {
      sku_name            = "Standard"
      redis_version       = 6
      cluster_shard_count = 4
      capacity            = 5
      redis_configuration = {
        maxmemory_reserved              = 2704
        maxmemory_delta                 = 2704
        maxfragmentationmemory_reserved = 2704
        maxmemory_policy                = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
    prod_small = {
      sku_name            = "Premium"
      redis_version       = 6
      cluster_shard_count = 2
      capacity            = 2
      redis_configuration = {
        maxmemory_reserved = 299
        maxmemory_delta    = 299
        maxfragmentationmemory_reserved = 299
        maxmemory_policy   = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"

        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
    prod_medium = {
      sku_name            = "Premium"
      redis_version       = 6
      cluster_shard_count = 2
      capacity            = 4
      redis_configuration = {
        maxmemory_reserved = 1330
        maxmemory_delta    = 1330
        maxfragmentationmemory_reserved = 1330
        maxmemory_policy   = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"

        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
    prod_large = {
      sku_name            = "Premium"
      redis_version       = 6
      cluster_shard_count = 4
      capacity            = 5
      redis_configuration = {
        maxmemory_reserved = 2704
        maxmemory_delta    = 2704
        maxfragmentationmemory_reserved = 2704
        maxmemory_policy   = "allkeys-lru"
      }
      patch_schedule = [
        {
          day_of_week        = "Monday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        },
        {
          day_of_week        = "Tuesday"
          start_hour_utc     = 6
          maintenance_window = "PT5H"
        }
      ]
      redis_firewall_rules = [
        {
          name     = "access_to_redis"
          start_ip = "10.0.0.0"
          end_ip   = "11.0.0.0"
        }
      ]
    },
  }
}

variable "kv_ids" {
  description = "Keyvault ID Map"
  type = map(object({
    spn_names = optional(list(string))
    ad_groups = optional(list(string))
  }))
  default = {
    np = {
      spn_names = []
      ad_groups = []
    },
    pre = {
      spn_names = ["azg1dbasql011"]
      ad_groups = []
    },
    prod = {
      spn_names = ["azg1dbasql011"]
      ad_groups = []
    },
  }
}



#-------------------------------------------------------------
# IAC Resource Module Outputs
#-------------------------------------------------------------

output "defaults" {
  value = module.infra_kit
}