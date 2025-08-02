# Terraform version and provider requirements
terraform {
  required_version = ">= 1.12.0"

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
  #   key                  = "foundry-agents/terraform.tfstate"
  #   subscription_id      = "00000000-0000-0000-0000-000000000000"
  #   tenant_id           = "11111111-1111-1111-1111-111111111111"
  #   use_azuread_auth    = true
  #   use_oidc            = true
  # }

  # For local development, use local backend
  backend "local" {}
}
