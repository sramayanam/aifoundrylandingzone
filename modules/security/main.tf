# =============================================================================
# Security Module (Simplified - No Cosmos DB)
# =============================================================================

# Data source for current configuration
data "azurerm_client_config" "current" {}

# Key Vault for secrets and encryption keys
resource "azurerm_key_vault" "main" {
  count = var.create_key_vault ? 1 : 0

  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku

  # Security settings
  enabled_for_disk_encryption     = var.enable_disk_encryption
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = true
  purge_protection_enabled        = var.environment == "prod" ? true : false
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days

  # Network access
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Private endpoint for Key Vault
resource "azurerm_private_endpoint" "key_vault" {
  count = var.create_key_vault && var.enable_private_endpoints ? 1 : 0

  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.main[0].id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.key_vault_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "${var.key_vault_name}-dns-zone-group"
      private_dns_zone_ids = var.key_vault_dns_zone_ids
    }
  }

  tags = var.tags
}

# Customer-managed key for storage encryption
resource "azurerm_key_vault_key" "storage_encryption" {
  count = var.create_key_vault && var.enable_customer_managed_keys ? 1 : 0

  name         = "${var.project_name}-storage-encryption-key"
  key_vault_id = azurerm_key_vault.main[0].id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = var.tags
}

# Storage account with customer-managed keys
resource "azurerm_storage_account_customer_managed_key" "main" {
  count = var.enable_customer_managed_keys ? 1 : 0

  storage_account_id = var.storage_account_id
  key_vault_id       = var.create_key_vault ? azurerm_key_vault.main[0].id : var.existing_key_vault_id
  key_name           = var.create_key_vault ? azurerm_key_vault_key.storage_encryption[0].name : var.existing_storage_key_name
}

# Managed Identity for additional security operations
resource "azurerm_user_assigned_identity" "security_identity" {
  count = var.create_security_identity ? 1 : 0

  location            = var.location
  name                = "${var.project_name}-security-identity"
  resource_group_name = var.resource_group_name

  tags = var.tags
}
