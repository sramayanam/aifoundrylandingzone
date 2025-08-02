# =============================================================================
# Monitoring Module Outputs (Simplified - No Cosmos DB)
# =============================================================================

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : try(azurerm_log_analytics_workspace.main[0].id, null)
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = try(azurerm_log_analytics_workspace.main[0].name, null)
}

output "application_insights_id" {
  description = "ID of Application Insights"
  value       = try(azurerm_application_insights.main[0].id, null)
}

output "application_insights_name" {
  description = "Name of Application Insights"
  value       = try(azurerm_application_insights.main[0].name, null)
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = try(azurerm_application_insights.main[0].instrumentation_key, null)
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = try(azurerm_application_insights.main[0].connection_string, null)
  sensitive   = true
}

output "action_group_id" {
  description = "ID of the action group"
  value       = try(azurerm_monitor_action_group.main[0].id, null)
}

output "action_group_name" {
  description = "Name of the action group"
  value       = try(azurerm_monitor_action_group.main[0].name, null)
}

output "diagnostic_settings" {
  description = "Diagnostic settings information"
  value = {
    storage    = try(azurerm_monitor_diagnostic_setting.storage[0].id, null)
    search     = try(azurerm_monitor_diagnostic_setting.search[0].id, null)
    ai_foundry = try(azurerm_monitor_diagnostic_setting.ai_foundry[0].id, null)
  }
}

output "alerts" {
  description = "Alert information"
  value = {
    storage_availability = try(azurerm_monitor_metric_alert.storage_availability[0].id, null)
    search_query_rate    = try(azurerm_monitor_metric_alert.search_query_rate[0].id, null)
  }
}
