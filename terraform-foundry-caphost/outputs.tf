output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.main.name
}

output "ai_foundry_id" {
  description = "Resource ID of the AI Foundry account"
  value       = azapi_resource.ai_foundry.id
}

output "ai_foundry_project_id" {
  description = "Resource ID of the AI Foundry Project"
  value       = azapi_resource.ai_foundry_project.id
}

output "ai_foundry_endpoint" {
  description = "Endpoint URL for the AI Foundry service"
  value       = "https://${azapi_resource.ai_foundry.name}.cognitiveservices.azure.com/"
  sensitive   = true
}

output "ai_foundry_name" {
  description = "Name of the AI Foundry account"
  value       = azapi_resource.ai_foundry.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "search_service_name" {
  description = "Name of the AI Search service"
  value       = azapi_resource.ai_search.name
}

output "cosmos_account_name" {
  description = "Name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmos_database_name" {
  description = "Name of the Cosmos DB database for thread storage"
  value       = azurerm_cosmosdb_sql_database.main.name
}

# Key Vault output removed - not needed for AI Foundry deployment

output "user_assigned_identity_id" {
  description = "Resource ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.id
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.client_id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.main.name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "project_capability_host_id" {
  description = "Resource ID of the project capability host"
  value       = azapi_resource.project_capability_host.id
}

output "agent_subnet_id" {
  description = "Resource ID of the agent subnet used for network injection"
  value       = data.azurerm_subnet.agent.id
}

output "private_endpoint_subnet_id" {
  description = "Resource ID of the private endpoint subnet"
  value       = data.azurerm_subnet.private_endpoint.id
}

output "deployment_summary" {
  description = "Summary of the deployed resources and their purposes"
  value = {
    ai_foundry = {
      foundry_name = azapi_resource.ai_foundry.name
      project_name = azapi_resource.ai_foundry_project.name
      endpoint     = "https://ai.azure.com"
      architecture = "AI Foundry with Project-based Capability Hosts"
    }
    capability_hosts = {
      project_level = azapi_resource.project_capability_host.name
      description   = "Configured for agents with custom storage, search, and thread storage"
    }
    storage_services = {
      file_storage   = azurerm_storage_account.main.name
      vector_storage = azapi_resource.ai_search.name
      thread_storage = azurerm_cosmosdb_account.main.name
    }
    ai_services = {
      foundry_account = azapi_resource.ai_foundry.name
      models = [
        "gpt-4o",
        "text-embedding-3-small"
      ]
    }
    networking = {
      agent_subnet_delegation = "Microsoft.CognitiveServices/accounts"
      private_endpoints_count = 5
      network_security        = "All services isolated with private endpoints"
    }
    next_steps = [
      "Verify capability hosts in Azure AI Foundry portal",
      "Create your first agent to test thread storage",
      "Configure monitoring alerts for Cosmos DB",
      "Set up backup policies for critical data"
    ]
  }
}

output "terraform_state_location" {
  description = "Location of the Terraform state for this deployment"
  value = {
    backend_type    = "azurerm"
    storage_account = "aaaorgtfstorage"
    container       = "tfstatecaphost"
    key             = "terraform-foundry-caphost.tfstate"
    resource_group  = "rg-terraform"
    access_method   = "ARM_SUBSCRIPTION_ID environment variable"
  }
}

output "cost_estimate" {
  description = "Estimated monthly costs for the deployed resources"
  value = {
    cosmos_db            = "$25-50/month (depending on throughput)"
    ai_search            = "$250/month (Standard tier)"
    storage_account      = "$5-20/month (depending on usage)"
    openai_models        = "$Pay-per-use (depends on token consumption)"
    key_vault            = "$2/month"
    application_insights = "$5-25/month (depending on telemetry volume)"
    total_estimated      = "$287-352/month + OpenAI usage"
    note                 = "Costs vary based on usage patterns and data retention"
  }
}
