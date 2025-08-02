# =============================================================================
# RBAC Module - Simplified Role-Based Access Control (No Cosmos DB)
# =============================================================================

# Data source for current configuration
data "azurerm_client_config" "current" {}

# =============================================================================
# AI Foundry Account Roles for Core Services (Account-level managed identity)
# =============================================================================

# Storage Blob Data Contributor role for AI Foundry account
resource "azurerm_role_assignment" "storage_blob_data_contributor_ai_foundry_account" {
  name                 = uuidv5("dns", "${var.ai_foundry_account_name}${var.ai_foundry_account_principal_id}${var.storage_account_name}storageblobdatacontributor")
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.ai_foundry_account_principal_id
}

# Search Service Contributor role for AI Foundry account
resource "azurerm_role_assignment" "search_service_contributor_ai_foundry_account" {
  name                 = uuidv5("dns", "${var.ai_foundry_account_name}${var.ai_foundry_account_principal_id}${var.search_service_name}searchservicecontributor")
  scope                = var.search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = var.ai_foundry_account_principal_id
}

# =============================================================================
# AI Foundry Project Roles for Core Services
# =============================================================================

# Storage Blob Data Contributor role for AI Foundry project
resource "azurerm_role_assignment" "storage_blob_data_contributor_ai_foundry_project" {
  name                 = uuidv5("dns", "${var.ai_foundry_project_name}${var.ai_foundry_project_principal_id}${var.storage_account_name}storageblobdatacontributor")
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.ai_foundry_project_principal_id
}

# Search Index Data Contributor role for AI Foundry project
resource "azurerm_role_assignment" "search_index_data_contributor_ai_foundry_project" {
  name                 = uuidv5("dns", "${var.ai_foundry_project_name}${var.ai_foundry_project_principal_id}${var.search_service_name}searchindexdatacontributor")
  scope                = var.search_service_id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = var.ai_foundry_project_principal_id
}

# Search Service Contributor role for AI Foundry project
resource "azurerm_role_assignment" "search_service_contributor_ai_foundry_project" {
  name                 = uuidv5("dns", "${var.ai_foundry_project_name}${var.ai_foundry_project_principal_id}${var.search_service_name}searchservicecontributor")
  scope                = var.search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = var.ai_foundry_project_principal_id
}

# Storage Blob Data Owner role for AI Foundry project (simplified without complex conditions)
resource "azurerm_role_assignment" "storage_blob_data_owner_ai_foundry_project" {
  name                 = uuidv5("dns", "${var.ai_foundry_project_name}${var.ai_foundry_project_principal_id}${var.storage_account_name}storageblobdataowner")
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.ai_foundry_project_principal_id
}

# =============================================================================
# Key Vault Roles (if Key Vault is created)
# =============================================================================

# Key Vault Administrator role for current user/service principal
resource "azurerm_role_assignment" "key_vault_admin" {
  count = var.create_key_vault ? 1 : 0

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Key Vault Crypto User role for AI Foundry project managed identity
resource "azurerm_role_assignment" "ai_foundry_key_vault_user" {
  count = var.create_key_vault && var.enable_customer_managed_keys ? 1 : 0

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = var.ai_foundry_project_principal_id
}

# Additional Key Vault Administrator roles
resource "azurerm_role_assignment" "additional_key_vault_admins" {
  for_each = var.create_key_vault ? toset(var.additional_key_vault_administrators) : []

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

# Additional Key Vault Crypto User roles
resource "azurerm_role_assignment" "additional_key_vault_users" {
  for_each = var.create_key_vault ? toset(var.additional_key_vault_users) : []

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = each.value
}

# =============================================================================
# Optional: Reader roles for monitoring and troubleshooting
# =============================================================================

# Reader role for AI Foundry project on the resource group (optional)
resource "azurerm_role_assignment" "ai_foundry_resource_group_reader" {
  count = var.environment == "dev" ? 1 : 0 # Only in dev environment for troubleshooting

  name                 = uuidv5("dns", "${var.ai_foundry_project_name}${var.ai_foundry_project_principal_id}${var.resource_group_name}reader")
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = var.ai_foundry_project_principal_id
}

# =============================================================================
# Platform Admin Users - Essential Permissions Only
# =============================================================================

# Storage Blob Data Contributor role for platform admin users
resource "azurerm_role_assignment" "platform_admin_users_storage_blob_data_contributor" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

# Storage Blob Data Owner role for platform admin users (simplified)
resource "azurerm_role_assignment" "platform_admin_users_storage_blob_data_owner" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = each.value
}

# Search Index Data Contributor role for platform admin users
resource "azurerm_role_assignment" "platform_admin_users_search_index_data_contributor" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = var.search_service_id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = each.value
}

# Search Service Contributor role for platform admin users
resource "azurerm_role_assignment" "platform_admin_users_search_service_contributor" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = var.search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = each.value
}

# Cognitive Services User role for platform admin users (AI Foundry Account)
# This role is essential for users to interact with AI services
resource "azurerm_role_assignment" "platform_admin_users_cognitive_services_user_account" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = var.ai_foundry_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = each.value
}

# Cognitive Services User role for platform admin users (AI Foundry Project)
resource "azurerm_role_assignment" "platform_admin_users_cognitive_services_user_project" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = var.ai_foundry_project_id
  role_definition_name = "Cognitive Services User"
  principal_id         = each.value
}

# Azure AI User role for platform admin users (AI Foundry Account)
resource "azurerm_role_assignment" "platform_admin_users_azure_ai_user_account" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = var.ai_foundry_account_id
  role_definition_name = "Azure AI User"
  principal_id         = each.value
}

# Azure AI User role for platform admin users (AI Foundry Project)
resource "azurerm_role_assignment" "platform_admin_users_azure_ai_user_project" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = var.ai_foundry_project_id
  role_definition_name = "Azure AI User"
  principal_id         = each.value
}

# Key Vault access for platform admin users (if Key Vault created)
resource "azurerm_role_assignment" "platform_admin_users_key_vault_admin" {
  for_each = var.create_key_vault ? toset(var.platform_admin_user_object_ids) : []

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

# Resource group Reader access for platform admin users (all environments)
resource "azurerm_role_assignment" "platform_admin_users_resource_group_reader" {
  for_each = toset(var.platform_admin_user_object_ids)

  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = each.value
}

# =============================================================================
# Platform Admin Groups - Essential Permissions Only
# =============================================================================

# Storage Blob Data Contributor role for platform admin groups
resource "azurerm_role_assignment" "platform_admin_groups_storage_blob_data_contributor" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

# Storage Blob Data Owner role for platform admin groups (simplified)
resource "azurerm_role_assignment" "platform_admin_groups_storage_blob_data_owner" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = each.value
}

# Search Index Data Contributor role for platform admin groups
resource "azurerm_role_assignment" "platform_admin_groups_search_index_data_contributor" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = var.search_service_id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = each.value
}

# Search Service Contributor role for platform admin groups
resource "azurerm_role_assignment" "platform_admin_groups_search_service_contributor" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = var.search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = each.value
}

# Cognitive Services User role for platform admin groups (AI Foundry Account)
# This role is essential for group members to interact with AI services
resource "azurerm_role_assignment" "platform_admin_groups_cognitive_services_user_account" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = var.ai_foundry_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = each.value
}

# Cognitive Services User role for platform admin groups (AI Foundry Project)
resource "azurerm_role_assignment" "platform_admin_groups_cognitive_services_user_project" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = var.ai_foundry_project_id
  role_definition_name = "Cognitive Services User"
  principal_id         = each.value
}

# Azure AI User role for platform admin groups (AI Foundry Account)
resource "azurerm_role_assignment" "platform_admin_groups_azure_ai_user_account" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = var.ai_foundry_account_id
  role_definition_name = "Azure AI User"
  principal_id         = each.value
}

# Azure AI User role for platform admin groups (AI Foundry Project)
resource "azurerm_role_assignment" "platform_admin_groups_azure_ai_user_project" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = var.ai_foundry_project_id
  role_definition_name = "Azure AI User"
  principal_id         = each.value
}

# Key Vault access for platform admin groups (if Key Vault created)
resource "azurerm_role_assignment" "platform_admin_groups_key_vault_admin" {
  for_each = var.create_key_vault ? toset(var.platform_admin_group_object_ids) : []

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

# Resource group Reader access for platform admin groups (all environments)
resource "azurerm_role_assignment" "platform_admin_groups_resource_group_reader" {
  for_each = toset(var.platform_admin_group_object_ids)

  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = each.value
}
