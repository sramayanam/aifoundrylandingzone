# =============================================================================
# Security Module Outputs (Simplified - No Cosmos DB)
# =============================================================================

# Key Vault Outputs
output "key_vault_id" {
  description = "ID of the created Key Vault"
  value       = length(azurerm_key_vault.main) > 0 ? azurerm_key_vault.main[0].id : null
}

output "key_vault_name" {
  description = "Name of the created Key Vault"
  value       = length(azurerm_key_vault.main) > 0 ? azurerm_key_vault.main[0].name : null
}

output "key_vault_uri" {
  description = "URI of the created Key Vault"
  value       = length(azurerm_key_vault.main) > 0 ? azurerm_key_vault.main[0].vault_uri : null
}

# Key Vault Private Endpoint Outputs
output "key_vault_private_endpoint_id" {
  description = "ID of the Key Vault private endpoint"
  value       = length(azurerm_private_endpoint.key_vault) > 0 ? azurerm_private_endpoint.key_vault[0].id : null
}

output "key_vault_private_endpoint_ip" {
  description = "Private IP address of the Key Vault private endpoint"
  value = length(azurerm_private_endpoint.key_vault) > 0 ? (
    length(azurerm_private_endpoint.key_vault[0].private_service_connection) > 0 ?
    azurerm_private_endpoint.key_vault[0].private_service_connection[0].private_ip_address : null
  ) : null
}

# Encryption Key Outputs
output "storage_encryption_key_id" {
  description = "ID of the storage encryption key"
  value       = length(azurerm_key_vault_key.storage_encryption) > 0 ? azurerm_key_vault_key.storage_encryption[0].id : null
}

output "storage_encryption_key_name" {
  description = "Name of the storage encryption key"
  value       = length(azurerm_key_vault_key.storage_encryption) > 0 ? azurerm_key_vault_key.storage_encryption[0].name : null
}

output "storage_encryption_key_version" {
  description = "Version of the storage encryption key"
  value       = length(azurerm_key_vault_key.storage_encryption) > 0 ? azurerm_key_vault_key.storage_encryption[0].version : null
}

# Customer-Managed Key Configuration Outputs
output "storage_cmk_enabled" {
  description = "Whether customer-managed keys are enabled for storage"
  value       = length(azurerm_storage_account_customer_managed_key.main) > 0
}

# Security Identity Outputs
output "security_identity_id" {
  description = "ID of the security managed identity"
  value       = length(azurerm_user_assigned_identity.security_identity) > 0 ? azurerm_user_assigned_identity.security_identity[0].id : null
}

output "security_identity_principal_id" {
  description = "Principal ID of the security managed identity"
  value       = length(azurerm_user_assigned_identity.security_identity) > 0 ? azurerm_user_assigned_identity.security_identity[0].principal_id : null
}

output "security_identity_client_id" {
  description = "Client ID of the security managed identity"
  value       = length(azurerm_user_assigned_identity.security_identity) > 0 ? azurerm_user_assigned_identity.security_identity[0].client_id : null
}

# Summary Output
output "security_summary" {
  description = "Summary of security configurations"
  value = {
    key_vault_created             = length(azurerm_key_vault.main) > 0
    key_vault_private_endpoint    = length(azurerm_private_endpoint.key_vault) > 0
    customer_managed_keys_enabled = length(azurerm_storage_account_customer_managed_key.main) > 0
    security_identity_created     = length(azurerm_user_assigned_identity.security_identity) > 0

    encryption_keys = {
      storage = length(azurerm_key_vault_key.storage_encryption) > 0 ? {
        name    = azurerm_key_vault_key.storage_encryption[0].name
        version = azurerm_key_vault_key.storage_encryption[0].version
      } : null
    }
  }
}
