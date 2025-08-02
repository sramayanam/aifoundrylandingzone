terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~>4.30"
      configuration_aliases = [azurerm.infra_subscription]
    }
  }
}
