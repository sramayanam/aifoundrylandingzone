# =============================================================================
# RBAC Module Variables (Simplified - No Cosmos DB)
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# AI Foundry Identity
variable "ai_foundry_account_name" {
  description = "Name of the AI Foundry account"
  type        = string
}

variable "ai_foundry_account_principal_id" {
  description = "Principal ID of AI Foundry account managed identity"
  type        = string
}

variable "ai_foundry_project_name" {
  description = "Name of the AI Foundry project"
  type        = string
}

variable "ai_foundry_project_principal_id" {
  description = "Principal ID of AI Foundry project managed identity"
  type        = string
}

# Resource IDs for role assignments
variable "storage_account_id" {
  description = "Storage account resource ID"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
}

variable "search_service_id" {
  description = "AI Search service resource ID"
  type        = string
}

variable "search_service_name" {
  description = "AI Search service name"
  type        = string
}

variable "ai_foundry_account_id" {
  description = "AI Foundry account resource ID"
  type        = string
}

variable "ai_foundry_project_id" {
  description = "AI Foundry project resource ID"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID (if created)"
  type        = string
  default     = null
}

# Additional principals for Key Vault access
variable "additional_key_vault_administrators" {
  description = "Additional principals to grant Key Vault Administrator role"
  type        = list(string)
  default     = []
}

variable "additional_key_vault_users" {
  description = "Additional principals to grant Key Vault Crypto User role"
  type        = list(string)
  default     = []
}

# Feature flags
variable "enable_customer_managed_keys" {
  description = "Enable customer-managed keys (affects Key Vault roles)"
  type        = bool
  default     = false
}

variable "create_key_vault" {
  description = "Whether Key Vault was created (affects Key Vault roles)"
  type        = bool
  default     = false
}

# Platform Admin Access
variable "platform_admin_user_object_ids" {
  description = "List of user object IDs to grant platform admin access (same permissions as managed identity)"
  type        = list(string)
  default     = []
}

variable "platform_admin_group_object_ids" {
  description = "List of group object IDs to grant platform admin access (same permissions as managed identity)"
  type        = list(string)
  default     = []
}
