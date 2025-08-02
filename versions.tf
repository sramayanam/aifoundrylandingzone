# Terraform version and provider requirements
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.3"
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
  # Comment out for local development
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "terraformstate"
  #   container_name       = "tfstate"
  #   key                  = "foundry-agents-nocaphost/terraform.tfstate"
  #   subscription_id      = "32e739cb-7b23-4259-a180-e1e0e69b974d"
  #   tenant_id           = "8429325e-77e2-4bd9-9f1e-4be922d474df"
  #   use_azuread_auth    = true
  #   use_oidc            = true
  # }

  # For local development, use local backend
  backend "local" {}
}
