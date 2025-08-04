# Private endpoints for secure network connectivity

# Key Vault private endpoint removed - not needed for AI Foundry deployment

# Private endpoint for Storage Account
resource "azurerm_private_endpoint" "storage" {
  name                = "${local.resource_prefix}-st-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${local.resource_prefix}-st-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.storage_blob_dns_zone_id]
  }

  tags = local.common_tags
}

# Private endpoint for AI Search
resource "azurerm_private_endpoint" "search" {
  name                = "${local.resource_prefix}-search-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${local.resource_prefix}-search-psc"
    private_connection_resource_id = azapi_resource.ai_search.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.search_dns_zone_id]
  }

  tags = local.common_tags
}

# Private endpoint for Cosmos DB
resource "azurerm_private_endpoint" "cosmos" {
  name                = "${local.resource_prefix}-cosmos-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${local.resource_prefix}-cosmos-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.cosmos_dns_zone_id]
  }

  tags = local.common_tags
}

# Private endpoint for AI Foundry
resource "azurerm_private_endpoint" "ai_foundry" {
  name                = "${local.resource_prefix}-foundry-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${local.resource_prefix}-foundry-psc"
    private_connection_resource_id = azapi_resource.ai_foundry.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      var.dns_zone_cognitiveservices,
      var.dns_zone_ai_services,
      var.dns_zone_openai_azure
    ]
  }

  tags = local.common_tags
}
