# =============================================================================
# Monitoring and Alerting Module (Simplified - No Cosmos DB)
# =============================================================================

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  count = var.create_log_analytics_workspace ? 1 : 0

  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  count = var.enable_application_insights ? 1 : 0

  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : try(azurerm_log_analytics_workspace.main[0].id, null)

  tags = var.tags
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  count = var.enable_alerts ? 1 : 0

  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = "aiagents"

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

# Diagnostic Settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "storage" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${var.project_name}-storage-diagnostics"
  target_resource_id         = var.storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : try(azurerm_log_analytics_workspace.main[0].id, null)

  # Storage Account logs - use metrics only as log categories vary by storage type
  # enabled_log blocks removed due to API incompatibility

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic Settings for AI Search
resource "azurerm_monitor_diagnostic_setting" "search" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${var.project_name}-search-diagnostics"
  target_resource_id         = var.search_service_id
  log_analytics_workspace_id = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : try(azurerm_log_analytics_workspace.main[0].id, null)

  dynamic "enabled_log" {
    for_each = var.search_log_categories
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic Settings for AI Foundry
resource "azurerm_monitor_diagnostic_setting" "ai_foundry" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${var.project_name}-ai-foundry-diagnostics"
  target_resource_id         = var.ai_foundry_id
  log_analytics_workspace_id = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : try(azurerm_log_analytics_workspace.main[0].id, null)

  # AI Foundry logs and metrics
  enabled_log {
    category = "Audit"
  }

  enabled_log {
    category = "RequestResponse"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Storage Account Availability Alert
resource "azurerm_monitor_metric_alert" "storage_availability" {
  count = var.enable_alerts && var.storage_account_id != null ? 1 : 0

  name                = "${var.project_name}-storage-availability-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.storage_account_id]
  description         = "Alert when storage account availability drops below threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.storage_availability_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  tags = var.tags
}

# AI Search Query Rate Alert
resource "azurerm_monitor_metric_alert" "search_query_rate" {
  count = var.enable_alerts && var.search_service_id != null ? 1 : 0

  name                = "${var.project_name}-search-query-rate-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.search_service_id]
  description         = "Alert when AI Search query rate is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Search/searchServices"
    metric_name      = "SearchQueriesPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.search_query_rate_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  tags = var.tags
}
