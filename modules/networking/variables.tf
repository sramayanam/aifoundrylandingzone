# =============================================================================
# Networking Module Variables (Simplified - No Cosmos DB, No Agent Subnet)
# =============================================================================

variable "project_name" {
  description = "The name of the project. Used for naming resources."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where resources will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Private Endpoint Configuration
# =============================================================================

variable "enable_private_endpoints" {
  description = "Whether to create private endpoints for services."
  type        = bool
  default     = true
}

variable "subnet_id_private_endpoint" {
  description = "The subnet ID where private endpoints will be created."
  type        = string
  default     = null
}

# =============================================================================
# Storage Account Configuration
# =============================================================================

variable "storage_account_id" {
  description = "The ID of the Storage Account to create private endpoint for."
  type        = string
  default     = null
}

variable "enable_file_shares" {
  description = "Whether to enable file shares and create file private endpoint."
  type        = bool
  default     = false
}

variable "storage_blob_dns_zone_id" {
  description = "The ID of the private DNS zone for storage blob (privatelink.blob.core.windows.net)."
  type        = string
  default     = null
}

variable "storage_file_dns_zone_id" {
  description = "The ID of the private DNS zone for storage file (privatelink.file.core.windows.net)."
  type        = string
  default     = null
}

# =============================================================================
# AI Search Configuration
# =============================================================================

variable "search_service_id" {
  description = "The ID of the AI Search service to create private endpoint for."
  type        = string
  default     = null
}

variable "search_dns_zone_id" {
  description = "The ID of the private DNS zone for AI Search (privatelink.search.windows.net)."
  type        = string
  default     = null
}

# =============================================================================
# AI Foundry/Cognitive Services Configuration
# =============================================================================

variable "ai_foundry_id" {
  description = "The ID of the AI Foundry/Cognitive Services account to create private endpoint for."
  type        = string
  default     = null
}

variable "dns_zone_cognitiveservices" {
  description = "The ID of the private DNS zone for cognitive services (privatelink.cognitiveservices.azure.com)."
  type        = string
  default     = null
}

variable "dns_zone_openai" {
  description = "The ID of the private DNS zone for OpenAI (privatelink.openai.azure.com)."
  type        = string
  default     = null
}

variable "dns_zone_ai_services" {
  description = "The ID of the private DNS zone for AI services (privatelink.services.ai.azure.com)."
  type        = string
  default     = null
}

# =============================================================================
# Network Security Configuration
# =============================================================================

variable "create_nsg_for_private_endpoints" {
  description = "Whether to create a Network Security Group for the private endpoints subnet."
  type        = bool
  default     = true
}

variable "additional_allowed_ports" {
  description = "Additional ports to allow in the NSG for private endpoints (beyond 80 and 443)."
  type        = list(string)
  default     = []
}

variable "create_route_table" {
  description = "Whether to create a route table for the private endpoints subnet."
  type        = bool
  default     = false
}

variable "custom_routes" {
  description = "Custom routes to add to the route table."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}
