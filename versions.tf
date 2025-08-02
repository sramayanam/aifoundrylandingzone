# Terraform version and provider requirements
terraform {
  required_version = ">= 1.12.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.3"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Remote state backend configuration  
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "aaaorgtfstorage"
    container_name       = "tfstate"
    key                  = "ai-foundry-nocaphost/terraform.tfstate"
    # subscription_id will be read from ARM_SUBSCRIPTION_ID environment variable
    use_azuread_auth     = true
  }

  # For local development, comment out the backend above and use:
  # backend "local" {}
}
