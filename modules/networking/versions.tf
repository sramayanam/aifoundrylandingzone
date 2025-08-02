terraform {
  required_version = ">= 1.12.0"

  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~>4.30"
      configuration_aliases = [azurerm.infra_subscription]
    }
  }
}
