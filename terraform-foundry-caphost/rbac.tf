# RBAC assignments for user-assigned managed identity

# Storage Blob Data Contributor for the storage account
resource "azurerm_role_assignment" "storage_contributor" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Key Vault removed - not needed for AI Foundry deployment

# Cognitive Services OpenAI Contributor for AI Foundry account
resource "azurerm_role_assignment" "openai_contributor" {
  scope                = azapi_resource.ai_foundry.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Search Index Data Contributor for AI Search
resource "azurerm_role_assignment" "search_contributor" {
  scope                = azapi_resource.ai_search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Search Service Contributor for AI Search management
resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azapi_resource.ai_search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# DocumentDB Account Contributor for Cosmos DB
resource "azurerm_role_assignment" "cosmos_contributor" {
  scope                = azurerm_cosmosdb_account.main.id
  role_definition_name = "DocumentDB Account Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Application Insights Component Contributor
resource "azurerm_role_assignment" "ai_administrator" {
  scope                = azurerm_application_insights.main.id
  role_definition_name = "Application Insights Component Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# RBAC for platform admin users on AI Foundry Project
resource "azurerm_role_assignment" "admin_users_ai_foundry_project" {
  for_each = toset(var.platform_admin_users)

  scope                = azapi_resource.ai_foundry_project.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = each.value
  principal_type       = "User"

  depends_on = [azapi_resource.ai_foundry_project]
}

resource "azurerm_role_assignment" "admin_groups_ai_foundry_project" {
  for_each = toset(var.platform_admin_groups)

  scope                = azapi_resource.ai_foundry_project.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = each.value
  principal_type       = "Group"

  depends_on = [azapi_resource.ai_foundry_project]
}

# RBAC for platform admin users
resource "azurerm_role_assignment" "admin_users_contributor" {
  for_each = toset(var.platform_admin_users)

  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = each.value
  principal_type       = "User"
}

resource "azurerm_role_assignment" "admin_groups_contributor" {
  for_each = toset(var.platform_admin_groups)

  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

# Optional resource group reader assignments (can be disabled if they already exist)
resource "azurerm_role_assignment" "admin_users_rg_reader" {
  for_each = var.create_resource_group_reader_assignments ? toset(var.platform_admin_users) : toset([])

  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = each.value
  principal_type       = "User"
}

resource "azurerm_role_assignment" "admin_groups_rg_reader" {
  for_each = var.create_resource_group_reader_assignments ? toset(var.platform_admin_groups) : toset([])

  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

# Data plane RBAC for Cosmos DB - these require the capability host to exist first
# This will be applied after the project is created and containers are available


# Note: Cosmos DB data plane RBAC assignments would be created here
# after the AI Foundry project creates the containers automatically.
# This requires custom azapi resources since Terraform doesn't have
# native support for Cosmos DB RBAC on containers yet.

# For now, we'll document this as a manual step or future enhancement.
