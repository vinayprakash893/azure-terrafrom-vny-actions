# -------------------------------------------------------------
# Localsa
# -------------------------------------------------------------


locals {
  input_variables_content = jsondecode(file("input-data.json"))
  subscription = local.input_variables_content["Subscription"]
  location     = local.input_variables_content["tf_workspace_name"]
  wfname     = local.input_variables_content["tf_workspace_name"]
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
      name = var.tf_workspace_name
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