# =============================================================================
# Security Module Variables (Simplified - No Cosmos DB)
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Key Vault Configuration
variable "create_key_vault" {
  description = "Whether to create a new Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = null
}

variable "existing_key_vault_id" {
  description = "ID of existing Key Vault to use"
  type        = string
  default     = null
}

variable "key_vault_sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "key_vault_soft_delete_retention_days" {
  description = "Number of days to retain deleted keys"
  type        = number
  default     = 90
  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days."
  }
}

variable "enable_disk_encryption" {
  description = "Enable Key Vault for disk encryption"
  type        = bool
  default     = false
}

# Private Endpoints Configuration
variable "enable_private_endpoints" {
  description = "Enable private endpoints for Key Vault"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
  default     = null
}

variable "key_vault_dns_zone_ids" {
  description = "DNS zone IDs for Key Vault private endpoint"
  type        = list(string)
  default     = []
}

# Customer-Managed Keys Configuration
variable "enable_customer_managed_keys" {
  description = "Enable customer-managed keys for encryption"
  type        = bool
  default     = false
}

variable "storage_account_id" {
  description = "Storage account ID for CMK configuration"
  type        = string
  default     = null
}

variable "existing_storage_key_name" {
  description = "Name of existing storage encryption key"
  type        = string
  default     = null
}

# Managed Identity Configuration
variable "create_security_identity" {
  description = "Create managed identity for security operations"
  type        = bool
  default     = false
}
