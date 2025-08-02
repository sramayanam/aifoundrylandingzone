# =============================================================================
# Monitoring Module Variables (Simplified - No Cosmos DB)
# =============================================================================

variable "project_name" {
  description = "Name of the project"
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

# Log Analytics Configuration
variable "create_log_analytics_workspace" {
  description = "Whether to create a new Log Analytics workspace"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "ID of existing Log Analytics workspace"
  type        = string
  default     = null
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily quota in GB for Log Analytics"
  type        = number
  default     = -1
}

# Application Insights Configuration
variable "enable_application_insights" {
  description = "Enable Application Insights"
  type        = bool
  default     = true
}

variable "application_insights_name" {
  description = "Name of Application Insights"
  type        = string
  default     = null
}

# Diagnostic Settings Configuration (Simplified)
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = true
}

variable "storage_account_id" {
  description = "Storage account resource ID"
  type        = string
  default     = null
}

variable "search_service_id" {
  description = "AI Search service resource ID"
  type        = string
  default     = null
}

variable "ai_foundry_id" {
  description = "AI Foundry resource ID"
  type        = string
  default     = null
}

variable "search_log_categories" {
  description = "AI Search log categories to enable"
  type        = list(string)
  default     = ["OperationLogs"]
}

# Alerting Configuration
variable "enable_alerts" {
  description = "Enable monitoring alerts"
  type        = bool
  default     = false
}

variable "action_group_name" {
  description = "Name of the action group"
  type        = string
  default     = null
}

variable "alert_email_addresses" {
  description = "Email addresses for alerts"
  type        = list(string)
  default     = []
}

# Alert Thresholds (Simplified - No Cosmos DB)
variable "storage_availability_threshold" {
  description = "Storage availability threshold percentage"
  type        = number
  default     = 95
}

variable "search_query_rate_threshold" {
  description = "AI Search query rate threshold per second"
  type        = number
  default     = 10
}
