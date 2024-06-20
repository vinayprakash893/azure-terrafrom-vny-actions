
#---------------------------------------------------------------------------
# Terraform state Configuration
#---------------------------------------------------------------------------

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "app551-cam-np-terraform-backend-eastus2"
#     storage_account_name = "app551camnpue2tfsbackend"
#     container_name       = "tfsbackend"
#     key                  = "app551/np/camelot/eastus2/app98/infra-kit/infraeng-01.tfstate"
#   }
# }


data "terraform_remote_state" "cmk_defaults" {
  backend = "azurerm"

  config = {
    resource_group_name = "app551-cam-np-terraform-backend-eastus2"
    # resource_group_name  = "app551-cam-np-app98-ue2"
    storage_account_name = "app551camnpue2tfsbackend"
    # storage_account_name = "app551camnptfsbckue2sa"
    container_name = "tfsbackend"
    key            = "app551/np/ue2/tfsbackends.tfstate"
  }
}

# -------------------------------------------------------------
# Locals
# -------------------------------------------------------------


locals {
  input_variables_content = jsondecode(file("input-data.json"))
  subscription            = local.input_variables_content["Subscription"]                         //app551
  location                = local.input_variables_content["jinja_Region"]                         // eastus2
  environment             = var.env_map[local.input_variables_content["Environment"]]["env_name"] // np
  DateCreated             = "03/04/24"

  aks_cluster = local.input_variables_content["jinja_Sub_Environment_Name"] // app98 //purpose
  # aks_cluster           = local.input_variables_content["Cluster_ref"] // app98 //purpose
  application_name      = local.input_variables_content["Application_Name"]       //dfcoreinfraeng 
  application_shortname = local.input_variables_content["Application_Short_Name"] // infraeng

  spn_names = ["app551-terraform-iac-spn", "jmd501-terraform-ne-app"]
  ad_groups = []

  team_aad_group = "AdminRole-IT-InfraEng-cloud"

  # -------------------------------------------------------------
  # Flags to deploy resources
  # -------------------------------------------------------------
  enable_dfid_integration = true
  enable_regional_db      = true
  enable_client_db        = true
  enable_kafka_secret     = true
  enable_storage_accounts = true
  enable_redis_cache      = false
  redis_size              = "small"

  size                             = "${local.environment}_${local.redis_size}"
  enable_sa_blob_private_endpoints = true
  enable_redis_private_endpoints   = true // has to be false if using internal subnet

  # Make sure your public IP in in KV and SA if you choose Deny 
  sa_firewall_action = "Allow" //"Deny"
  kv_firewall_action = "Allow" //"Deny"

  storage_ip_rules = [
    "136.226.72.178",
    "136.226.74.188",
    "3.219.95.0"
  ]

  keyvault_ip_rules = [
    "136.226.74.205/32",
    "142.198.57.174/32",
    "136.226.74.188/32",
    "3.219.95.0/32"
  ]

  enable_tfc_remote_state              = true
  tfc_org                              = "DayforceCloud"
  tier1_camelot_defaults_tfc_workspace = "cie-az-${local.subscription}_tier1_camelot_defaults"
  tier2_tfc_workspace                  = "cie-az-${local.subscription}_aks_cluster_${local.location}_${local.aks_cluster}_tier2"
  tier3_tfc_workspace                  = "cie-az-${local.subscription}_aks_cluster_${local.location}_${local.aks_cluster}_tier3"


  # -------------------------------------------------------------
  # Namespace
  # -------------------------------------------------------------
  namespace = {
    ns1 = {
      name      = "${local.application_name}"
      team_name = local.application_name
      umi_name  = "${local.subscription}-cam-${local.application_name}-${var.region_map[local.location]["location_name"]}-identity"

      tags = {
        DateCreated = local.DateCreated
      },
    }

  }

  # -------------------------------------------------------------
  # Keyvaults
  # -------------------------------------------------------------

  keyvault = {
    "kv1" = {
      keyvault_ip_rules         = local.keyvault_ip_rules
      default_action            = local.kv_firewall_action
      purge_protection_enabled  = false
      enable_rbac_authorization = true
      ns_key                    = "ns1"
      kv_name                   = local.application_shortname
      rbac_access = {
        "Key Vault Secrets Officer" = {
          spn_names = local.enable_regional_db == true || local.enable_client_db == true ? concat(local.spn_names, var.kv_ids[local.environment]["spn_names"]) : local.spn_names
          ad_groups = local.enable_regional_db == true || local.enable_client_db == true ? concat(local.ad_groups, var.kv_ids[local.environment]["ad_groups"]) : local.ad_groups
        },
        "Key Vault Secrets User" = {
          spn_names = local.spn_names
          ad_groups = local.ad_groups
        }
      }
    },
  }


  # -------------------------------------------------------------
  # Storage Accounts
  # -------------------------------------------------------------

  key_vault_key_id = data.terraform_remote_state.cmk_defaults.outputs.kv_cmk_key_id
  cmk_identity_id  = data.terraform_remote_state.cmk_defaults.outputs.kv_user_identity_id
  identity_ids     = [data.terraform_remote_state.cmk_defaults.outputs.kv_user_identity_id]

  storage_accounts = {
    "sa01" = {
      name = "${local.subscription}${local.environment}${local.application_shortname}${var.region_map[local.location]["location_name"]}sa"
      //${local.subscription}${local.application_shortname}${local.environment}${var.region_map[local.location]["location_name"]}sa"
      ns_key                          = "ns1"
      account_tier                    = "Standard"
      account_replication_type        = "LRS"
      account_kind                    = "StorageV2"
      min_tls_version                 = "TLS1_2"
      sku                             = "Standard_LRS"
      cmk_enabled                     = true
      allow_nested_items_to_be_public = false
      infra_encryption_enabled        = true
      smb                             = null
      management_policy_rules         = null
      network_rules = {
        ip_rules       = local.storage_ip_rules
        bypass         = ["AzureServices"]
        default_action = local.sa_firewall_action
      }
    },
  }

  # -------------------------------------------------------------
  # Redis Cache
  # -------------------------------------------------------------


  redis_cache = {
    "rc01" = {
      ns_key = "ns1"
      name   = "${local.subscription}-${local.environment}-${local.application_shortname}-${var.region_map[local.location]["location_name"]}-redis"
      //${local.subscription}-${local.application_shortname}-${local.environment}-${var.region_map[local.location]["location_name"]}-redis
      sku_name             = var.redis_map[local.size]["sku_name"]            // "Premium"
      redis_version        = var.redis_map[local.size]["redis_version"]       //6
      cluster_shard_count  = var.redis_map[local.size]["cluster_shard_count"] //2
      capacity             = var.redis_map[local.size]["capacity"]            //2
      patch_schedule       = var.redis_map[local.size]["patch_schedule"]
      redis_configuration  = var.redis_map[local.size]["redis_configuration"]
      redis_firewall_rules = var.redis_map[local.size]["redis_firewall_rules"]

    }


  }

  tags = {
    EnvironmentName      = "Non Production"
    SubEnvironmentName   = ""
    CreatedBy            = "app551-terraform-iac-spn"
    ProvisioningTeam     = "cloudinfrastructureengineering@ceridian.com"
    ProductOwner         = "infraeng@ceridian.com"
    DevTeam              = "cloudinfrastructureengineering@ceridian.com"
    Classification       = ""
    Purpose              = "Infra Kit"
    SubPurpose           = "core platform"
    BillTo               = "Dayforce Development"
    DateCreated          = local.DateCreated
    ProvisioningResource = "terraform"
    ProvisioningProcess  = "automated"
    EndDate              = ""
  }
}