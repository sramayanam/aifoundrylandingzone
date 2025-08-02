# =============================================================================
# RBAC Module Outputs (Simplified - No Cosmos DB)
# =============================================================================

# AI Foundry Account Role Assignment IDs
output "ai_foundry_account_storage_role_assignment_id" {
  description = "ID of the Storage Blob Data Contributor role assignment for AI Foundry account"
  value       = azurerm_role_assignment.storage_blob_data_contributor_ai_foundry_account.id
}

output "ai_foundry_account_search_role_assignment_id" {
  description = "ID of the Search Service Contributor role assignment for AI Foundry account"
  value       = azurerm_role_assignment.search_service_contributor_ai_foundry_account.id
}

# AI Foundry Project Role Assignment IDs
output "ai_foundry_project_storage_contributor_role_assignment_id" {
  description = "ID of the Storage Blob Data Contributor role assignment for AI Foundry project"
  value       = azurerm_role_assignment.storage_blob_data_contributor_ai_foundry_project.id
}

output "ai_foundry_project_storage_owner_role_assignment_id" {
  description = "ID of the Storage Blob Data Owner role assignment for AI Foundry project"
  value       = azurerm_role_assignment.storage_blob_data_owner_ai_foundry_project.id
}

output "ai_foundry_project_search_data_role_assignment_id" {
  description = "ID of the Search Index Data Contributor role assignment for AI Foundry project"
  value       = azurerm_role_assignment.search_index_data_contributor_ai_foundry_project.id
}

output "ai_foundry_project_search_service_role_assignment_id" {
  description = "ID of the Search Service Contributor role assignment for AI Foundry project"
  value       = azurerm_role_assignment.search_service_contributor_ai_foundry_project.id
}

# Key Vault Role Assignment IDs (if created)
output "key_vault_admin_role_assignment_id" {
  description = "ID of the Key Vault Administrator role assignment for current user"
  value       = length(azurerm_role_assignment.key_vault_admin) > 0 ? azurerm_role_assignment.key_vault_admin[0].id : null
}

output "ai_foundry_key_vault_user_role_assignment_id" {
  description = "ID of the Key Vault Crypto User role assignment for AI Foundry project"
  value       = length(azurerm_role_assignment.ai_foundry_key_vault_user) > 0 ? azurerm_role_assignment.ai_foundry_key_vault_user[0].id : null
}

# Platform Admin Role Assignment Summary
output "platform_admin_users_role_assignments" {
  description = "Summary of role assignments for platform admin users"
  value = {
    storage_contributor = [for ra in azurerm_role_assignment.platform_admin_users_storage_blob_data_contributor : ra.id]
    storage_owner       = [for ra in azurerm_role_assignment.platform_admin_users_storage_blob_data_owner : ra.id]
    search_data         = [for ra in azurerm_role_assignment.platform_admin_users_search_index_data_contributor : ra.id]
    search_service      = [for ra in azurerm_role_assignment.platform_admin_users_search_service_contributor : ra.id]
    key_vault_admin     = [for ra in azurerm_role_assignment.platform_admin_users_key_vault_admin : ra.id]
    resource_reader     = [for ra in azurerm_role_assignment.platform_admin_users_resource_group_reader : ra.id]
  }
}

output "platform_admin_groups_role_assignments" {
  description = "Summary of role assignments for platform admin groups"
  value = {
    storage_contributor = [for ra in azurerm_role_assignment.platform_admin_groups_storage_blob_data_contributor : ra.id]
    storage_owner       = [for ra in azurerm_role_assignment.platform_admin_groups_storage_blob_data_owner : ra.id]
    search_data         = [for ra in azurerm_role_assignment.platform_admin_groups_search_index_data_contributor : ra.id]
    search_service      = [for ra in azurerm_role_assignment.platform_admin_groups_search_service_contributor : ra.id]
    key_vault_admin     = [for ra in azurerm_role_assignment.platform_admin_groups_key_vault_admin : ra.id]
    resource_reader     = [for ra in azurerm_role_assignment.platform_admin_groups_resource_group_reader : ra.id]
  }
}

# Additional Key Vault Role Assignments (if created)
output "additional_key_vault_admin_role_assignments" {
  description = "IDs of additional Key Vault Administrator role assignments"
  value       = [for ra in azurerm_role_assignment.additional_key_vault_admins : ra.id]
}

output "additional_key_vault_user_role_assignments" {
  description = "IDs of additional Key Vault Crypto User role assignments"
  value       = [for ra in azurerm_role_assignment.additional_key_vault_users : ra.id]
}

# Overall RBAC Summary
output "rbac_summary" {
  description = "Summary of all RBAC configurations"
  value = {
    ai_foundry_account_roles = {
      storage_contributor = azurerm_role_assignment.storage_blob_data_contributor_ai_foundry_account.id
      search_contributor  = azurerm_role_assignment.search_service_contributor_ai_foundry_account.id
    }
    ai_foundry_project_roles = {
      storage_contributor = azurerm_role_assignment.storage_blob_data_contributor_ai_foundry_project.id
      storage_owner       = azurerm_role_assignment.storage_blob_data_owner_ai_foundry_project.id
      search_data         = azurerm_role_assignment.search_index_data_contributor_ai_foundry_project.id
      search_service      = azurerm_role_assignment.search_service_contributor_ai_foundry_project.id
    }
    key_vault_enabled           = var.create_key_vault
    platform_admin_users_count  = length(var.platform_admin_user_object_ids)
    platform_admin_groups_count = length(var.platform_admin_group_object_ids)
  }
}
