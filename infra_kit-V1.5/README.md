# tier9-infra_kit

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.48.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.99.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_action_groups"></a> [action\_groups](#module\_action\_groups) | git@github.com:DayforceCloud/terraform-azurerm-alerting//modules/action_groups// | v1.2.7 |
| <a name="module_kv"></a> [kv](#module\_kv) | git@github.com:dayforcecloud/terraform-azurerm-keyvault.git// | v1.0.14 |
| <a name="module_kv_ma"></a> [kv\_ma](#module\_kv\_ma) | git@github.com:DayforceCloud/terraform-azurerm-alerting//modules/metric// | v1.2.7 |
| <a name="module_pe_blob_storage"></a> [pe\_blob\_storage](#module\_pe\_blob\_storage) | git@github.com:dayforcecloud/terraform-azurerm-private-endpoint.git// | v1.0.8 |
| <a name="module_pe_cache_redis"></a> [pe\_cache\_redis](#module\_pe\_cache\_redis) | git@github.com:dayforcecloud/terraform-azurerm-private-endpoint// | v1.0.8 |
| <a name="module_pe_keyvault"></a> [pe\_keyvault](#module\_pe\_keyvault) | git@github.com:dayforcecloud/terraform-azurerm-private-endpoint.git// | v1.0.7 |
| <a name="module_redis_cache"></a> [redis\_cache](#module\_redis\_cache) | git@github.com:dayforcecloud/terraform-azurerm-redis-cache.git// | v1.2.3 |
| <a name="module_redis_ma"></a> [redis\_ma](#module\_redis\_ma) | git@github.com:DayforceCloud/terraform-azurerm-alerting//modules/metric// | v1.2.7 |
| <a name="module_rg"></a> [rg](#module\_rg) | git@github.com:dayforcecloud/terraform-azurerm-resource-group.git// | v1.0.6 |
| <a name="module_sa"></a> [sa](#module\_sa) | git@github.com:dayforcecloud/terraform-azurerm-storage-account.git// | v1.1.11 |
| <a name="module_sa_ma"></a> [sa\_ma](#module\_sa\_ma) | git@github.com:DayforceCloud/terraform-azurerm-alerting//modules/metric// | v1.2.7 |

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.oidc_aks_fed](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_key_vault_secret.appinsights_connection_string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.client_db_support_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.dfid_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.kafka_bootstrap_url](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.primary_connection_string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.regional_db_support_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.secondary_connection_string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.storage_account_connection_string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.aks_cluster_user_umi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.reader_user_umi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uami](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uami_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uami_reader_sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uami_sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.redis_managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.um_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azuread_group.ad_groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [terraform_remote_state.azure_tier1_defaults](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.azure_tier2_network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.azure_tier3_aks_cluster](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.tfc_tier1_defaults](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.tfc_tier2_network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.tfc_tier3_aks_cluster](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_emails"></a> [action\_group\_emails](#input\_action\_group\_emails) | n/a | <pre>list(object({<br>    name                    = string<br>    email_address           = string<br>    use_common_alert_schema = optional(bool, true)<br>  }))</pre> | `[]` | no |
| <a name="input_action_group_enabled"></a> [action\_group\_enabled](#input\_action\_group\_enabled) | Enable or disable team action group. | `bool` | `true` | no |
| <a name="input_action_group_webhooks"></a> [action\_group\_webhooks](#input\_action\_group\_webhooks) | n/a | <pre>list(object({<br>    name                    = string<br>    service_uri             = string<br>    use_common_alert_schema = optional(bool, true)<br>    use_aad_auth            = optional(bool, false)<br>    aad_auth = optional(object({<br>      object_id      = string<br>      identifier_uri = string<br>      tenant_id      = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_aks_purpose"></a> [aks\_purpose](#input\_aks\_purpose) | Purpose use for naming resources | `string` | `"camelot"` | no |
| <a name="input_aks_purpose_short"></a> [aks\_purpose\_short](#input\_aks\_purpose\_short) | Purpose use for naming resources shortname | `string` | `"cam"` | no |
| <a name="input_assign_identity"></a> [assign\_identity](#input\_assign\_identity) | n/a | `string` | `"UserAssigned"` | no |
| <a name="input_blobs"></a> [blobs](#input\_blobs) | Map of blobs | `map` | `{}` | no |
| <a name="input_cmk_identity_id"></a> [cmk\_identity\_id](#input\_cmk\_identity\_id) | Identity ID used when using Customer Managed Keys | `string` | `null` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | Map of Storage Containers for storage account | `map` | `{}` | no |
| <a name="input_data_persistence_backup_frequency"></a> [data\_persistence\_backup\_frequency](#input\_data\_persistence\_backup\_frequency) | The Backup Frequency in Minutes. Only supported on Premium SKU's. Possible values are: `15`, `30`, `60`, `360`, `720` and `1440` | `number` | `60` | no |
| <a name="input_data_persistence_backup_max_snapshot_count"></a> [data\_persistence\_backup\_max\_snapshot\_count](#input\_data\_persistence\_backup\_max\_snapshot\_count) | The maximum number of snapshots to create as a backup. Only supported for Premium SKU's | `number` | `1` | no |
| <a name="input_data_persistence_enabled"></a> [data\_persistence\_enabled](#input\_data\_persistence\_enabled) | Enable or disbale Redis Database Backup. Only supported on Premium SKU's | `bool` | `true` | no |
| <a name="input_enable_client_db"></a> [enable\_client\_db](#input\_enable\_client\_db) | Enable Client DB Support | `bool` | `false` | no |
| <a name="input_enable_dfid_integration"></a> [enable\_dfid\_integration](#input\_enable\_dfid\_integration) | Enable DFID Integration | `bool` | `false` | no |
| <a name="input_enable_kafka_secret"></a> [enable\_kafka\_secret](#input\_enable\_kafka\_secret) | Enable Kafka Secret | `bool` | `false` | no |
| <a name="input_enable_keyvault"></a> [enable\_keyvault](#input\_enable\_keyvault) | Enable Keyvault | `bool` | `false` | no |
| <a name="input_enable_kv_private_endpoints"></a> [enable\_kv\_private\_endpoints](#input\_enable\_kv\_private\_endpoints) | Enable PE for keyvault | `bool` | `false` | no |
| <a name="input_enable_non_ssl_port"></a> [enable\_non\_ssl\_port](#input\_enable\_non\_ssl\_port) | Enable the non-SSL port (6379) - disabled by default. | `bool` | `false` | no |
| <a name="input_enable_redis_cache"></a> [enable\_redis\_cache](#input\_enable\_redis\_cache) | Enable Redis Cache | `bool` | `false` | no |
| <a name="input_enable_redis_private_endpoints"></a> [enable\_redis\_private\_endpoints](#input\_enable\_redis\_private\_endpoints) | Enable PE for Redis Cache | `bool` | `false` | no |
| <a name="input_enable_regional_db"></a> [enable\_regional\_db](#input\_enable\_regional\_db) | Enable Regional DB Support | `bool` | `false` | no |
| <a name="input_enable_sa_blob_private_endpoints"></a> [enable\_sa\_blob\_private\_endpoints](#input\_enable\_sa\_blob\_private\_endpoints) | Enable PE for Storage Accounts | `bool` | `true` | no |
| <a name="input_enable_storage_accounts"></a> [enable\_storage\_accounts](#input\_enable\_storage\_accounts) | Enable Storage Accounts | `bool` | `false` | no |
| <a name="input_enable_tfc_remote_state"></a> [enable\_tfc\_remote\_state](#input\_enable\_tfc\_remote\_state) | Use Terraform Cloud Remote State | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name for application | `string` | `null` | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | Map of file shares | `map` | `{}` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of Managed Identities | `list(string)` | `null` | no |
| <a name="input_key_vault_key_id"></a> [key\_vault\_key\_id](#input\_key\_vault\_key\_id) | KeyVault Key ID used for Customer Managed Key encryption. | `string` | `null` | no |
| <a name="input_keyvault"></a> [keyvault](#input\_keyvault) | n/a | `map` | `{}` | no |
| <a name="input_keyvault_name"></a> [keyvault\_name](#input\_keyvault\_name) | Manually entered Key Vault Name | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy service(s) into | `string` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version. Possible values are 1.0, 1.1 and 1.2. Defaults to 1.0. | `string` | `"1.2"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Name of Namespace | `map(any)` | `{}` | no |
| <a name="input_private_dns_zone"></a> [private\_dns\_zone](#input\_private\_dns\_zone) | (Required) Provate DNS zone name to build resource ID. | `string` | `"/subscriptions/68a4597f-4bd5-4df8-b717-165bdb017332/resourceGroups/ss101-dns-pe-prod-eastus2/providers/Microsoft.Network/privateDnsZones"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for this Key Vault. Defaults to true. | `bool` | `true` | no |
| <a name="input_purpose"></a> [purpose](#input\_purpose) | Reason for building azure resource | `string` | `null` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | Map of queues | `map` | `{}` | no |
| <a name="input_redis_cache"></a> [redis\_cache](#input\_redis\_cache) | Map of Redis Cache which needs to be created in a resource group | `any` | n/a | yes |
| <a name="input_redis_public_network_access_enabled"></a> [redis\_public\_network\_access\_enabled](#input\_redis\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for this redis. Defaults to true. | `bool` | `false` | no |
| <a name="input_redis_subnet_id_number"></a> [redis\_subnet\_id\_number](#input\_redis\_subnet\_id\_number) | (optional) The subnet id number / index used with cache\_subnet\_id in redis for data reference lookup. | `number` | `4` | no |
| <a name="input_region_map_location"></a> [region\_map\_location](#input\_region\_map\_location) | n/a | <pre>map(object({<br>    location = string<br><br>  }))</pre> | <pre>{<br>  "australiaeast": {<br>    "location": "aue"<br>  },<br>  "australiasoutheast": {<br>    "location": "ause"<br>  },<br>  "canadacentral": {<br>    "location": "cac"<br>  },<br>  "canadaeast": {<br>    "location": "cae"<br>  },<br>  "centralus": {<br>    "location": "uc"<br>  },<br>  "eastus2": {<br>    "location": "ue2"<br>  },<br>  "northeurope": {<br>    "location": "eun"<br>  },<br>  "southeastasia": {<br>    "location": "ase"<br>  },<br>  "westeurope": {<br>    "location": "euw"<br>  }<br>}</pre> | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Keyvault sku | `string` | `"premium"` | no |
| <a name="input_storage_accounts"></a> [storage\_accounts](#input\_storage\_accounts) | Map of storage accounts | `map` | `{}` | no |
| <a name="input_subscription"></a> [subscription](#input\_subscription) | Subscription where resource resides | `string` | `null` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | Map of tables | `map` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that are added to resource | `map(string)` | `{}` | no |
| <a name="input_team_aad_group"></a> [team\_aad\_group](#input\_team\_aad\_group) | This should use an azure objectId of the AD group that will have permissions to administer the AKS cluster. | `string` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Name of Teams resource | `string` | `null` | no |
| <a name="input_tfc_org"></a> [tfc\_org](#input\_tfc\_org) | Terraform Cloud organization | `string` | `null` | no |
| <a name="input_tier1_remote_state_container"></a> [tier1\_remote\_state\_container](#input\_tier1\_remote\_state\_container) | remote tfstate storage container | `string` | `null` | no |
| <a name="input_tier1_remote_state_key"></a> [tier1\_remote\_state\_key](#input\_tier1\_remote\_state\_key) | remote tfstate storage key | `string` | `null` | no |
| <a name="input_tier1_remote_state_rg"></a> [tier1\_remote\_state\_rg](#input\_tier1\_remote\_state\_rg) | remote tfstate rg | `string` | `null` | no |
| <a name="input_tier1_remote_state_sa"></a> [tier1\_remote\_state\_sa](#input\_tier1\_remote\_state\_sa) | remote tfstate storage account | `string` | `null` | no |
| <a name="input_tier1_remote_state_sub_id"></a> [tier1\_remote\_state\_sub\_id](#input\_tier1\_remote\_state\_sub\_id) | remote tfstate subscription id | `string` | `null` | no |
| <a name="input_tier1_tfc_workspace"></a> [tier1\_tfc\_workspace](#input\_tier1\_tfc\_workspace) | Terraform Cloud workspace name for ak8s defaults | `string` | `null` | no |
| <a name="input_tier2_remote_state_container"></a> [tier2\_remote\_state\_container](#input\_tier2\_remote\_state\_container) | remote tfstate storage container | `string` | `null` | no |
| <a name="input_tier2_remote_state_key"></a> [tier2\_remote\_state\_key](#input\_tier2\_remote\_state\_key) | remote tfstate storage key | `string` | `null` | no |
| <a name="input_tier2_remote_state_rg"></a> [tier2\_remote\_state\_rg](#input\_tier2\_remote\_state\_rg) | remote tfstate rg | `string` | `null` | no |
| <a name="input_tier2_remote_state_sa"></a> [tier2\_remote\_state\_sa](#input\_tier2\_remote\_state\_sa) | remote tfstate storage account | `string` | `null` | no |
| <a name="input_tier2_remote_state_sub_id"></a> [tier2\_remote\_state\_sub\_id](#input\_tier2\_remote\_state\_sub\_id) | remote tfstate subscription id | `string` | `null` | no |
| <a name="input_tier2_tfc_workspace"></a> [tier2\_tfc\_workspace](#input\_tier2\_tfc\_workspace) | Terraform Cloud workspace name for Tier 2 | `string` | `null` | no |
| <a name="input_tier3_remote_state_container"></a> [tier3\_remote\_state\_container](#input\_tier3\_remote\_state\_container) | remote tfstate storage container | `string` | `null` | no |
| <a name="input_tier3_remote_state_key"></a> [tier3\_remote\_state\_key](#input\_tier3\_remote\_state\_key) | remote tfstate storage key | `string` | `null` | no |
| <a name="input_tier3_remote_state_rg"></a> [tier3\_remote\_state\_rg](#input\_tier3\_remote\_state\_rg) | remote tfstate rg | `string` | `null` | no |
| <a name="input_tier3_remote_state_sa"></a> [tier3\_remote\_state\_sa](#input\_tier3\_remote\_state\_sa) | remote tfstate storage account | `string` | `null` | no |
| <a name="input_tier3_remote_state_sub_id"></a> [tier3\_remote\_state\_sub\_id](#input\_tier3\_remote\_state\_sub\_id) | remote tfstate subscription id | `string` | `null` | no |
| <a name="input_tier3_tfc_workspace"></a> [tier3\_tfc\_workspace](#input\_tier3\_tfc\_workspace) | Terraform Cloud workspace name for Tier 3 | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_infra_output"></a> [infra\_output](#output\_infra\_output) | n/a |
| <a name="output_kv_map"></a> [kv\_map](#output\_kv\_map) | n/a |
| <a name="output_kv_name"></a> [kv\_name](#output\_kv\_name) | n/a |
| <a name="output_kv_uri"></a> [kv\_uri](#output\_kv\_uri) | n/a |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | n/a |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
