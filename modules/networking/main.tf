# =============================================================================
# Networking Module for Private Endpoints (Simplified - No Cosmos DB, No Agent Subnet)
# =============================================================================

# Private endpoint for Storage Account Blob
resource "azurerm_private_endpoint" "storage_blob" {
  count = var.enable_private_endpoints ? 1 : 0

  provider = azurerm.workload_subscription

  name                = "${var.project_name}-storage-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint

  private_service_connection {
    name                           = "${var.project_name}-storage-blob-psc"
    private_connection_resource_id = var.storage_account_id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.storage_blob_dns_zone_id != null ? [1] : []
    content {
      name                 = "${var.project_name}-storage-blob-dns-zone-group"
      private_dns_zone_ids = [var.storage_blob_dns_zone_id]
    }
  }

  tags = var.tags
}

# Private endpoint for Storage Account File
resource "azurerm_private_endpoint" "storage_file" {
  count = var.enable_private_endpoints && var.enable_file_shares && var.storage_account_id != null ? 1 : 0

  provider = azurerm.workload_subscription

  name                = "${var.project_name}-storage-file-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint

  private_service_connection {
    name                           = "${var.project_name}-storage-file-psc"
    private_connection_resource_id = var.storage_account_id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.storage_file_dns_zone_id != null ? [1] : []
    content {
      name                 = "${var.project_name}-storage-file-dns-zone-group"
      private_dns_zone_ids = [var.storage_file_dns_zone_id]
    }
  }

  tags = var.tags
}

# Private endpoint for AI Search
resource "azurerm_private_endpoint" "search" {
  count = var.enable_private_endpoints ? 1 : 0

  provider = azurerm.workload_subscription

  name                = "${var.project_name}-search-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint

  private_service_connection {
    name                           = "${var.project_name}-search-psc"
    private_connection_resource_id = var.search_service_id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.search_dns_zone_id != null ? [1] : []
    content {
      name                 = "${var.project_name}-search-dns-zone-group"
      private_dns_zone_ids = [var.search_dns_zone_id]
    }
  }

  tags = var.tags
}

# Private endpoint for AI Foundry (consolidated for all AI services)
# Handles privatelink.openai.azure.com, privatelink.cognitiveservices.azure.com, privatelink.services.ai.azure.com
resource "azurerm_private_endpoint" "ai_foundry" {
  count = var.enable_private_endpoints ? 1 : 0

  provider = azurerm.workload_subscription

  name                = "${var.project_name}-ai-foundry-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint

  private_service_connection {
    name                           = "${var.project_name}-ai-foundry-psc"
    private_connection_resource_id = var.ai_foundry_id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  # DNS zone group with multiple DNS zones for all AI services
  dynamic "private_dns_zone_group" {
    for_each = length(compact([var.dns_zone_cognitiveservices, var.dns_zone_openai, var.dns_zone_ai_services])) > 0 ? [1] : []
    content {
      name = "${var.project_name}-ai-foundry-dns-zone-group"
      private_dns_zone_ids = compact([
        var.dns_zone_cognitiveservices, # privatelink.cognitiveservices.azure.com
        var.dns_zone_openai,            # privatelink.openai.azure.com  
        var.dns_zone_ai_services        # privatelink.services.ai.azure.com
      ])
    }
  }

  tags = var.tags
}

# Network Security Group for private endpoints subnet
resource "azurerm_network_security_group" "private_endpoints" {
  count = var.create_nsg_for_private_endpoints ? 1 : 0

  name                = "${var.project_name}-pe-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTPS inbound from VNet
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow HTTP inbound from VNet (for some services)
  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow custom ports for AI services
  dynamic "security_rule" {
    for_each = var.additional_allowed_ports
    content {
      name                       = "AllowCustomPort${security_rule.value}"
      priority                   = 1100 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    }
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG with private endpoints subnet
resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  count = var.create_nsg_for_private_endpoints && var.subnet_id_private_endpoint != null ? 1 : 0

  subnet_id                 = var.subnet_id_private_endpoint
  network_security_group_id = azurerm_network_security_group.private_endpoints[0].id
}

# Route table for private endpoints (if needed)
resource "azurerm_route_table" "private_endpoints" {
  count = var.create_route_table ? 1 : 0

  name                = "${var.project_name}-pe-rt"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Route to force traffic through firewall/NVA if needed
  dynamic "route" {
    for_each = var.custom_routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = var.tags
}

# Associate route table with private endpoints subnet
resource "azurerm_subnet_route_table_association" "private_endpoints" {
  count = var.create_route_table && var.subnet_id_private_endpoint != null ? 1 : 0

  subnet_id      = var.subnet_id_private_endpoint
  route_table_id = azurerm_route_table.private_endpoints[0].id
}
