# Core Configuration
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "aifoundry"

  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.project_name))
    error_message = "Project name must be 3-10 characters, lowercase letters and numbers only."
  }
}

variable "project_friendly_name" {
  description = "Human-readable project name"
  type        = string
  default     = "AI Foundry Agent Project - Simplified"

  validation {
    condition     = length(var.project_friendly_name) <= 100
    error_message = "Project friendly name must be 100 characters or less."
  }
}

variable "project_description" {
  description = "Description of the AI Foundry project"
  type        = string
  default     = "Azure AI Foundry project for intelligent agents - simplified deployment without capability hosts"

  validation {
    condition     = length(var.project_description) <= 500
    error_message = "Project description must be 500 characters or less."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string

  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "northcentralus", "southcentralus",
      "westcentralus", "canadacentral", "canadaeast", "brazilsouth", "northeurope", "westeurope",
      "uksouth", "ukwest", "francecentral", "germanywestcentral", "switzerlandnorth", "norwayeast",
      "japaneast", "japanwest", "koreacentral", "southeastasia", "eastasia", "australiaeast",
      "australiasoutheast", "centralindia", "southindia", "westindia", "uaenorth"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name_resources" {
  description = "Name of the resource group for AI Foundry resources"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,90}$", var.resource_group_name_resources))
    error_message = "Resource group name must be 1-90 characters, alphanumeric, periods, underscores, hyphens and parentheses."
  }
}

# =============================================================================
# Subscription Configuration
# =============================================================================

variable "subscription_id_resources" {
  description = "Azure subscription ID where resources will be deployed"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id_resources))
    error_message = "Subscription ID must be a valid GUID format."
  }
}

variable "subscription_id_infra" {
  description = "Azure subscription ID where DNS zones are located (can be same as resources subscription)"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id_infra))
    error_message = "Infrastructure subscription ID must be a valid GUID format."
  }
}

# =============================================================================
# Network Configuration (Simplified - No Agent Subnet)
# =============================================================================

variable "subnet_id_private_endpoint" {
  description = "Resource ID of the subnet for private endpoints"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.subnet_id_private_endpoint))
    error_message = "Private endpoint subnet ID must be a valid Azure subnet resource ID."
  }
}

# =============================================================================
# Private DNS Zone Configuration (Removed Cosmos DB DNS Zone)
# =============================================================================

variable "dns_zone_cognitiveservices" {
  description = "Resource ID of the privatelink.cognitiveservices.azure.com DNS zone"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/privateDnsZones/privatelink\\.cognitiveservices\\.azure\\.com$", var.dns_zone_cognitiveservices))
    error_message = "Cognitive Services DNS zone ID must be a valid privatelink.cognitiveservices.azure.com zone resource ID."
  }
}

variable "dns_zone_openai" {
  description = "Resource ID of the privatelink.openai.azure.com DNS zone"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/privateDnsZones/privatelink\\.openai\\.azure\\.com$", var.dns_zone_openai))
    error_message = "OpenAI DNS zone ID must be a valid privatelink.openai.azure.com zone resource ID."
  }
}

variable "dns_zone_ai_services" {
  description = "Resource ID of the privatelink.services.ai.azure.com DNS zone"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/privateDnsZones/privatelink\\.services\\.ai\\.azure\\.com$", var.dns_zone_ai_services))
    error_message = "AI Services DNS zone ID must be a valid privatelink.services.ai.azure.com zone resource ID."
  }
}

variable "storage_blob_dns_zone_id" {
  description = "Resource ID of the privatelink.blob.core.windows.net DNS zone"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/privateDnsZones/privatelink\\.blob\\.core\\.windows\\.net$", var.storage_blob_dns_zone_id))
    error_message = "Storage blob DNS zone ID must be a valid privatelink.blob.core.windows.net zone resource ID."
  }
}

variable "search_dns_zone_id" {
  description = "Resource ID of the privatelink.search.windows.net DNS zone"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/privateDnsZones/privatelink\\.search\\.windows\\.net$", var.search_dns_zone_id))
    error_message = "Search DNS zone ID must be a valid privatelink.search.windows.net zone resource ID."
  }
}

# =============================================================================
# Resource Configuration
# =============================================================================


variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "ZRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Storage replication type must be one of: LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "search_sku" {
  description = "AI Search service SKU"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], var.search_sku)
    error_message = "Search SKU must be one of: free, basic, standard, standard2, standard3, storage_optimized_l1, storage_optimized_l2."
  }
}

variable "search_replica_count" {
  description = "Number of replicas for AI Search service"
  type        = number
  default     = 1

  validation {
    condition     = var.search_replica_count >= 1 && var.search_replica_count <= 12
    error_message = "Search replica count must be between 1 and 12."
  }
}

variable "search_partition_count" {
  description = "Number of partitions for AI Search service"
  type        = number
  default     = 1

  validation {
    condition     = contains([1, 2, 3, 4, 6, 12], var.search_partition_count)
    error_message = "Search partition count must be one of: 1, 2, 3, 4, 6, 12."
  }
}

variable "ai_foundry_sku" {
  description = "AI Foundry service SKU"
  type        = string
  default     = "S0"

  validation {
    condition     = contains(["F0", "S0"], var.ai_foundry_sku)
    error_message = "AI Foundry SKU must be either F0 (free) or S0 (standard)."
  }
}

# =============================================================================
# Security and Compliance (Simplified)
# =============================================================================

variable "enable_soft_delete" {
  description = "Enable soft delete for storage account"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable blob versioning for storage account"
  type        = bool
  default     = true
}

# =============================================================================
# Monitoring and Logging
# =============================================================================

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for resources"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic logs"
  type        = string
  default     = null

  validation {
    condition     = var.log_analytics_workspace_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.OperationalInsights/workspaces/[^/]+$", var.log_analytics_workspace_id))
    error_message = "Log Analytics workspace ID must be a valid workspace resource ID or null."
  }
}

variable "enable_alerts" {
  description = "Enable Azure Monitor alerts"
  type        = bool
  default     = false
}

variable "alert_email_addresses" {
  description = "List of email addresses for alert notifications"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.alert_email_addresses : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All email addresses must be valid email format."
  }
}

# =============================================================================
# Tags and Metadata
# =============================================================================

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for tag_key in keys(var.tags) : can(regex("^[a-zA-Z0-9+\\-=._/:@]{1,128}$", tag_key))
    ])
    error_message = "Tag keys must be 1-128 characters and contain only letters, numbers, and the characters + - = . _ / : @"
  }

  validation {
    condition = alltrue([
      for tag_value in values(var.tags) : can(regex("^[a-zA-Z0-9+\\-=._/:@\\s]{0,256}$", tag_value))
    ])
    error_message = "Tag values must be 0-256 characters and contain only letters, numbers, spaces, and the characters + - = . _ / : @"
  }
}

# =============================================================================
# Feature Flags
# =============================================================================

variable "enable_private_endpoints" {
  description = "Enable private endpoints for all services"
  type        = bool
  default     = true
}

variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity for resources"
  type        = bool
  default     = true
}

variable "enable_customer_managed_keys" {
  description = "Enable customer-managed keys for encryption"
  type        = bool
  default     = false
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault for customer-managed keys"
  type        = string
  default     = null

  validation {
    condition     = var.key_vault_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.KeyVault/vaults/[^/]+$", var.key_vault_id))
    error_message = "Key Vault ID must be a valid Key Vault resource ID or null."
  }
}

# =============================================================================
# User and Group Access Management
# =============================================================================

variable "platform_admin_users" {
  description = "List of user principal names (UPNs) to grant platform admin access"
  type        = list(string)
  default     = ["admin@example.com"]

  validation {
    condition = alltrue([
      for user in var.platform_admin_users : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", user))
    ])
    error_message = "All user principal names must be valid email format."
  }
}

variable "platform_admin_groups" {
  description = "List of Azure AD group object IDs to grant platform admin access"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for group_id in var.platform_admin_groups : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", group_id))
    ])
    error_message = "All group IDs must be valid GUID format."
  }
}

variable "create_resource_group_reader_assignments" {
  description = "Create resource group Reader role assignments for platform admins (disable if they already exist to prevent conflicts)"
  type        = bool
  default     = false # Default to false for better customer experience
}

# =============================================================================
# Development and Testing
# =============================================================================


# =============================================================================
# Additional Network Configuration Variables (Simplified)
# =============================================================================

variable "enable_service_endpoints" {
  description = "Enable service endpoints on subnets"
  type        = bool
  default     = false
}

variable "enable_forced_tunneling" {
  description = "Enable forced tunneling for private endpoints"
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed to access services"
  type        = list(string)
  default     = []
}

variable "enable_file_shares" {
  description = "Enable file share private endpoints"
  type        = bool
  default     = false
}

variable "additional_allowed_ports" {
  description = "Additional ports to allow in NSG rules"
  type        = list(string)
  default     = []
}

variable "custom_routes" {
  description = "Custom routes to add to the route table"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}

variable "storage_file_dns_zone_id" {
  description = "DNS zone ID for storage file private endpoints"
  type        = string
  default     = null
}

variable "key_vault_dns_zone_id" {
  description = "DNS zone ID for Key Vault private endpoints"
  type        = string
  default     = null
}

# =============================================================================
# OpenAI Deployment Configuration
# =============================================================================


