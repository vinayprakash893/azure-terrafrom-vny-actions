# -------------------------------------------------------------
# Localsa
# -------------------------------------------------------------
data "terraform_remote_state" "cmk_defaults" { 
   backend = "remote" 
  
   config = { 
     organization = "DayforceCloud" 
     workspaces = { 
       name = join("-", [local.subscription,"terraform-iac-spn"])
     } 
   } 
 } 


locals {
  input_variables_content = jsondecode(file("input-data.json"))
  subscription = local.input_variables_content["Subscription"]
  enable_dfid_integration   = local.input_variables_content["Additional_App_Infra"]["Blob_Storage_Type"]["Enabled"]
  enable_regional_db        = false
  enable_client_db          =  false
  # location     = local.input_variables_content["tf_workspace_name"]
  # wfname     = local.input_variables_content["tf_workspace_name"]
}


terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      "source" = "hashicorp/azurerm"
      version  = "3.43.0"
    }
  }
  cloud {
    organization = "Cloudtech"

    workspaces {
      name = "vny"
    }
  }
}

variable "tf_workspace_name" {
  description = "The name of the Terraform workspace"
  type        = string
  default     = "" # Optional: set a default value
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
}