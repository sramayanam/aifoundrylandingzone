variable "project_name" {
  description = "Name of the project - used as prefix for resource naming"
  type        = string
  default     = "aifoundry"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{1,19}$", var.project_name))
    error_message = "Project name must be 2-20 characters, start with a letter, and contain only letters and numbers."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "subscription_id_resources" {
  description = "Azure subscription ID where workload resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id_resources))
    error_message = "Subscription ID must be a valid UUID format."
  }
}

variable "subscription_id_infra" {
  description = "Azure subscription ID where infrastructure resources exist"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id_infra))
    error_message = "Subscription ID must be a valid UUID format."
  }
}

variable "resource_group_name_resources" {
  description = "Name of the resource group for workload resources"
  type        = string
  default     = "rg-agents-secured-caphost"
}

variable "subnet_id_private_endpoint" {
  description = "Resource ID of the subnet for private endpoints"
  type        = string
}

variable "subnet_id_agent" {
  description = "Resource ID of the subnet for agent network injection (must be delegated to Microsoft.CognitiveServices/accounts)"
  type        = string
}

variable "dns_zone_cognitiveservices" {
  description = "Resource ID of the private DNS zone for Cognitive Services"
  type        = string
}

variable "dns_zone_ai_services" {
  description = "Resource ID of the private DNS zone for AI Services (privatelink.services.ai.azure.com)"
  type        = string
}

variable "dns_zone_openai_azure" {
  description = "Resource ID of the private DNS zone for OpenAI Azure (privatelink.openai.azure.com)"
  type        = string
}

variable "storage_blob_dns_zone_id" {
  description = "Resource ID of the private DNS zone for Storage Blob"
  type        = string
}

variable "search_dns_zone_id" {
  description = "Resource ID of the private DNS zone for Azure Search"
  type        = string
}

variable "cosmos_dns_zone_id" {
  description = "Resource ID of the private DNS zone for Cosmos DB"
  type        = string
}

variable "platform_admin_users" {
  description = "List of user object IDs that should have admin access"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for user_id in var.platform_admin_users : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", user_id))
    ])
    error_message = "All user IDs must be valid UUID format (object IDs)."
  }
}

variable "platform_admin_groups" {
  description = "List of Azure AD group object IDs that should have admin access"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for group_id in var.platform_admin_groups : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", group_id))
    ])
    error_message = "All group IDs must be valid UUID format."
  }
}

variable "create_resource_group_reader_assignments" {
  description = "Whether to create resource group reader role assignments (set to false if they already exist)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.tags : can(regex("^[a-zA-Z0-9._-]+$", k)) && length(k) <= 512 && length(v) <= 256
    ])
    error_message = "Tag keys must be alphanumeric with periods, underscores, or hyphens, max 512 chars. Values max 256 chars."
  }
}
