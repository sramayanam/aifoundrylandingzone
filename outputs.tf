# Infrastructure Outputs

output "resource_prefix" {
  description = "Resource prefix used for naming"
  value       = local.resource_prefix
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "location" {
  description = "Azure region"
  value       = var.location
}

output "resource_group_name" {
  description = "Resource group name"
  value       = var.resource_group_name_resources
}

# Storage Account Outputs
output "storage_account" {
  description = "Storage account information"
  value = {
    id                    = azurerm_storage_account.storage_account.id
    name                  = azurerm_storage_account.storage_account.name
    primary_blob_endpoint = azurerm_storage_account.storage_account.primary_blob_endpoint
    primary_access_key    = azurerm_storage_account.storage_account.primary_access_key
  }
  sensitive = true
}

# AI Search Outputs
output "ai_search" {
  description = "AI Search service information"
  value = {
    id       = azapi_resource.ai_search.id
    name     = azapi_resource.ai_search.name
    endpoint = "https://${azapi_resource.ai_search.name}.search.windows.net/"
  }
}

# AI Foundry Outputs
output "ai_foundry" {
  description = "AI Foundry account information"
  value = {
    id               = azapi_resource.ai_foundry.id
    name             = azapi_resource.ai_foundry.name
    endpoint         = "https://${azapi_resource.ai_foundry.name}.cognitiveservices.azure.com/"
    custom_subdomain = "${local.resource_prefix}-foundry"
  }
}

# AI Foundry Project Outputs
output "ai_foundry_project" {
  description = "AI Foundry project information"
  value = {
    id           = azapi_resource.ai_foundry_project.id
    name         = azapi_resource.ai_foundry_project.name
    principal_id = azapi_resource.ai_foundry_project.output.identity.principalId
    internal_id  = try(azapi_resource.ai_foundry_project.output.properties.internalId, "N/A")
  }
}

# OpenAI Deployment Outputs
output "openai_deployment" {
  description = "OpenAI deployment information"
  value = {
    id            = azurerm_cognitive_deployment.aifoundry_deployment_gpt_4o.id
    name          = azurerm_cognitive_deployment.aifoundry_deployment_gpt_4o.name
    model_name    = azurerm_cognitive_deployment.aifoundry_deployment_gpt_4o.model[0].name
    model_version = azurerm_cognitive_deployment.aifoundry_deployment_gpt_4o.model[0].version
    endpoint      = "https://${azapi_resource.ai_foundry.name}.cognitiveservices.azure.com/"
  }
}

# Connection Information Outputs
output "connections" {
  description = "AI Foundry project connections"
  value = {
    storage_connection = {
      id   = azapi_resource.conn_storage.id
      name = azapi_resource.conn_storage.name
    }
    search_connection = {
      id   = azapi_resource.conn_aisearch.id
      name = azapi_resource.conn_aisearch.name
    }
    ai_services_connection = {
      id   = azapi_resource.conn_ai_services.id
      name = azapi_resource.conn_ai_services.name
    }
  }
}

# Module Outputs
output "monitoring" {
  description = "Monitoring module outputs"
  value       = module.monitoring
  sensitive   = true
}

output "security" {
  description = "Security module outputs"
  value       = module.security
  sensitive   = true
}

output "networking" {
  description = "Networking module outputs"
  value       = module.networking
}

output "rbac" {
  description = "RBAC module outputs"
  value       = module.rbac
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of the simplified AI Foundry deployment"
  value = {
    deployment_type         = "NoCapabilityHosts"
    ai_foundry_account_name = azapi_resource.ai_foundry.name
    ai_foundry_project_name = azapi_resource.ai_foundry_project.name
    storage_account_name    = azurerm_storage_account.storage_account.name
    ai_search_endpoint      = "https://${azapi_resource.ai_search.name}.search.windows.net/"
    openai_deployment_name  = azurerm_cognitive_deployment.aifoundry_deployment_gpt_4o.name

    # Private endpoint information (if enabled)
    private_endpoints_enabled = var.enable_private_endpoints
    use_private_dns           = var.enable_private_endpoints

    # Authentication information
    use_managed_identity = var.enable_managed_identity
    project_principal_id = azapi_resource.ai_foundry_project.output.identity.principalId

    # Simplified features
    cosmos_db_enabled        = false
    capability_hosts_enabled = false
    agent_subnet_required    = false
  }
}

# Network Configuration Summary (Simplified)
output "network_configuration" {
  description = "Network configuration summary"
  value = {
    private_endpoint_subnet_id = var.subnet_id_private_endpoint
    private_endpoints_enabled  = var.enable_private_endpoints
    service_endpoints_enabled  = var.enable_service_endpoints
    forced_tunneling_enabled   = var.enable_forced_tunneling

    # DNS zones used (without Cosmos DB)
    dns_zones = {
      storage_blob       = var.storage_blob_dns_zone_id
      search             = var.search_dns_zone_id
      cognitive_services = var.dns_zone_cognitiveservices
      openai             = var.dns_zone_openai
      ai_services        = var.dns_zone_ai_services
    }
  }
}

# Security Configuration Summary (Simplified)
output "security_configuration" {
  description = "Security configuration summary"
  value = {
    customer_managed_keys_enabled = var.enable_customer_managed_keys
    private_endpoints_enabled     = var.enable_private_endpoints
    managed_identity_enabled      = var.enable_managed_identity
    soft_delete_enabled           = var.enable_soft_delete
    versioning_enabled            = var.enable_versioning

    # Key Vault information (if created)
    key_vault_enabled = var.enable_customer_managed_keys
    key_vault_id      = try(module.security.key_vault_id, null)

    # Simplified security - no Cosmos DB encryption
    storage_encryption_enabled = true
    search_encryption_enabled  = true
  }
}

# Cost Estimation (Simplified)
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (USD)"
  value = {
    environment         = var.environment
    estimated_total_usd = local.current_env.estimated_monthly_cost
    ai_foundry_sku      = var.ai_foundry_sku
    search_sku          = var.search_sku
    storage_replication = var.storage_replication_type
    openai_sku          = local.current_env.openai_sku
    openai_capacity     = local.current_env.openai_capacity

    # Cost savings from simplified deployment
    cost_savings_notes = "Simplified deployment without Cosmos DB and capability hosts reduces estimated costs by ~30%"
  }
}

# Connection Details for Application Integration
output "application_integration" {
  description = "Information needed for application integration"
  value = {
    ai_foundry_endpoint = azapi_resource.ai_foundry.output.properties.endpoint
    search_endpoint     = "https://${azapi_resource.ai_search.name}.search.windows.net/"
    storage_endpoint    = azurerm_storage_account.storage_account.primary_blob_endpoint

    # Authentication
    use_managed_identity = var.enable_managed_identity
    project_principal_id = azapi_resource.ai_foundry_project.output.identity.principalId

    # Model deployment
    openai_deployment_name = azurerm_cognitive_deployment.aifoundry_deployment_gpt_4o.name
    openai_model_name      = azurerm_cognitive_deployment.aifoundry_deployment_gpt_4o.model[0].name
    openai_model_version   = azurerm_cognitive_deployment.aifoundry_deployment_gpt_4o.model[0].version

    # Simplified deployment notes
    deployment_notes = "This is a simplified AI Foundry deployment without capability hosts. Use standard Azure AI SDK for integration."
  }
}

# Terraform State Information
output "terraform_state" {
  description = "Terraform state information"
  value = {
    terraform_version = ">=1.10.0"
    provider_versions = {
      azapi   = "~>2.3"
      azurerm = "~>4.30"
      time    = "~>0.12"
      random  = "~>3.6"
    }
    backend_type = "local"
    resources_created = {
      storage_account    = 1
      ai_search          = 1
      ai_foundry         = 1
      ai_foundry_project = 1
      openai_deployment  = 1
      connections        = 3
      private_endpoints  = var.enable_private_endpoints ? 3 : 0
    }
  }
}
