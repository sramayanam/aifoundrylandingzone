# =============================================================================
# Azure AI Foundry Agent Service - Simplified Infrastructure (No Capability Hosts)
# =============================================================================

# Random string for unique resource naming
resource "random_string" "unique" {
  length      = 4
  min_numeric = 4
  numeric     = true
  special     = false
  lower       = true
  upper       = false
}

# =============================================================================
# Data Sources for User and Group Lookups
# =============================================================================

# Look up platform admin users
data "azuread_users" "platform_admin_users" {
  count                = length(var.platform_admin_users) > 0 ? 1 : 0
  user_principal_names = var.platform_admin_users
}

# Look up platform admin groups (if any)
data "azuread_groups" "platform_admin_groups" {
  count      = length(var.platform_admin_groups) > 0 ? 1 : 0
  object_ids = var.platform_admin_groups
}

# =============================================================================
# Modules
# =============================================================================

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name        = var.project_name
  location            = var.location
  resource_group_name = var.resource_group_name_resources
  tags                = local.common_tags

  # Log Analytics Configuration
  create_log_analytics_workspace = var.log_analytics_workspace_id == null
  log_analytics_workspace_name   = var.log_analytics_workspace_id == null ? "${var.project_name}-${local.env_short}-${random_string.unique.result}-law" : null
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_retention_days             = local.environment_config[var.environment].log_retention_days
  daily_quota_gb                 = local.environment_config[var.environment].daily_quota_gb

  # Application Insights
  enable_application_insights = var.enable_diagnostic_settings
  application_insights_name   = "${var.project_name}-${local.env_short}-${random_string.unique.result}-ins"

  # Diagnostic Settings
  enable_diagnostic_settings = var.enable_diagnostic_settings
  storage_account_id         = azurerm_storage_account.storage_account.id
  search_service_id          = azapi_resource.ai_search.id
  ai_foundry_id              = azapi_resource.ai_foundry.id
  # Removed cosmos_db_id reference

  # Alerting
  enable_alerts         = var.enable_alerts
  action_group_name     = var.enable_alerts ? "${var.project_name}-${local.env_short}-${random_string.unique.result}-alrt" : null
  alert_email_addresses = var.alert_email_addresses

  # Alert thresholds (environment-specific)
  storage_availability_threshold = local.environment_config[var.environment].storage_availability_threshold
  search_query_rate_threshold    = local.environment_config[var.environment].search_query_rate_threshold
  # Removed cosmos_ru_threshold reference
}

# Security Module
module "security" {
  source = "./modules/security"

  # Basic required variables (all defined in security/variables.tf)
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name_resources
  tags                = local.common_tags

  # Key Vault Configuration
  create_key_vault                     = var.enable_customer_managed_keys && var.key_vault_id == null
  key_vault_name                       = var.enable_customer_managed_keys && var.key_vault_id == null ? "${var.project_name}-${local.env_short}-${random_string.unique.result}-kv" : null
  existing_key_vault_id                = var.key_vault_id
  key_vault_sku                        = local.environment_config[var.environment].key_vault_sku
  key_vault_soft_delete_retention_days = local.environment_config[var.environment].key_vault_retention_days
  enable_disk_encryption               = var.enable_customer_managed_keys

  # Private Endpoints
  enable_private_endpoints   = var.enable_private_endpoints
  private_endpoint_subnet_id = var.subnet_id_private_endpoint
  key_vault_dns_zone_ids     = var.enable_private_endpoints && var.key_vault_dns_zone_id != null ? [var.key_vault_dns_zone_id] : []

  # Customer-Managed Keys
  enable_customer_managed_keys = var.enable_customer_managed_keys
  storage_account_id           = azurerm_storage_account.storage_account.id
  # Removed cosmos_db_id reference

  # Additional Security Features
  create_security_identity = true

  depends_on = [
    azurerm_storage_account.storage_account,
    azapi_resource.ai_foundry_project,
    time_sleep.wait_project_identities
  ]
}

# Networking Module (simplified)
module "networking" {
  source = "./modules/networking"

  providers = {
    azurerm.infra_subscription    = azurerm.infra_subscription
    azurerm.workload_subscription = azurerm.workload_subscription
  }

  project_name        = var.project_name
  location            = var.location
  resource_group_name = var.resource_group_name_resources
  tags                = local.common_tags

  # Subnet Configuration
  subnet_id_private_endpoint = var.subnet_id_private_endpoint
  # Removed subnet_id_agent reference

  # Private Endpoints
  enable_private_endpoints = var.enable_private_endpoints
  enable_file_shares       = var.enable_file_shares

  # Resource IDs (removed Cosmos DB)
  storage_account_id = azurerm_storage_account.storage_account.id
  search_service_id  = azapi_resource.ai_search.id
  ai_foundry_id      = azapi_resource.ai_foundry.id

  # DNS Zones (removed Cosmos DB)
  storage_blob_dns_zone_id   = var.storage_blob_dns_zone_id
  storage_file_dns_zone_id   = var.storage_file_dns_zone_id
  search_dns_zone_id         = var.search_dns_zone_id
  dns_zone_cognitiveservices = var.dns_zone_cognitiveservices
  dns_zone_openai            = var.dns_zone_openai
  dns_zone_ai_services       = var.dns_zone_ai_services

  # Network Security
  create_nsg_for_private_endpoints = false # Subnet already has NSG associated
  additional_allowed_ports         = var.additional_allowed_ports

  # Route Table (for advanced networking)
  create_route_table = var.enable_forced_tunneling
  custom_routes      = var.custom_routes

  depends_on = [
    azurerm_storage_account.storage_account,
    azapi_resource.ai_search,
    azapi_resource.ai_foundry
  ]
}

# =============================================================================
# Core Infrastructure Resources
# =============================================================================

# Storage Account for agent data
resource "azurerm_storage_account" "storage_account" {
  provider = azurerm.workload_subscription

  name                            = "aifoundry${random_string.unique.result}storage"
  resource_group_name             = var.resource_group_name_resources
  location                        = var.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  shared_access_key_enabled       = false
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = local.common_tags

  # Lifecycle management to prevent accidental deletion
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags["CreatedDate"],
      tags["LastModified"]
    ]
  }
}

# AI Search instance for vector embeddings
resource "azapi_resource" "ai_search" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.Search/searchServices@2024-06-01-preview"
  name                      = "${var.project_name}-${local.env_short}-${random_string.unique.result}-srch"
  parent_id                 = "/subscriptions/${var.subscription_id_resources}/resourceGroups/${var.resource_group_name_resources}"
  location                  = var.location
  schema_validation_enabled = true

  body = {
    sku = {
      name = var.search_sku
    }

    identity = {
      type = "SystemAssigned"
    }

    properties = {
      # Search-specific properties (environment-dependent)
      replicaCount   = var.search_replica_count
      partitionCount = var.search_partition_count
      hostingMode    = local.environment_config[var.environment].search_hosting_mode
      semanticSearch = local.environment_config[var.environment].semantic_search

      # Identity-related controls
      disableLocalAuth = local.environment_config[var.environment].disable_local_auth
      authOptions = {
        aadOrApiKey = {
          aadAuthFailureMode = "http401WithBearerChallenge"
        }
      }

      # Networking controls
      publicNetworkAccess = var.enable_private_endpoints ? "disabled" : "enabled"
      networkRuleSet = {
        bypass = "None"
        ipRules = var.enable_private_endpoints ? [] : [
          for ip in var.allowed_ip_ranges : {
            value = ip
          }
        ]
      }
    }
  }

  tags = local.common_tags

  # Lifecycle management to prevent accidental deletion
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags["CreatedDate"],
      tags["LastModified"]
    ]
  }
}

# =============================================================================
# AI Foundry Resources
# =============================================================================

# AI Foundry account (without network injection)
resource "azapi_resource" "ai_foundry" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.CognitiveServices/accounts@2025-04-01-preview"
  name                      = "${var.project_name}-${local.env_short}-${random_string.unique.result}-ai"
  parent_id                 = "/subscriptions/${var.subscription_id_resources}/resourceGroups/${var.resource_group_name_resources}"
  location                  = var.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices"
    sku = {
      name = var.ai_foundry_sku
    }
    identity = {
      type = var.enable_managed_identity ? "SystemAssigned" : "None"
    }

    properties = {
      # API properties
      apiProperties = {}

      # Support both Entra ID and API Key authentication for underlying Cognitive Services account
      disableLocalAuth = false

      # Specifies that this is an AI Foundry resource
      allowProjectManagement = true

      # Set custom subdomain name to match the AI Foundry resource name exactly
      customSubDomainName = "${var.project_name}-${local.env_short}-${random_string.unique.result}-ai"

      # Network-related controls (simplified without VNet injection)
      publicNetworkAccess = var.enable_private_endpoints ? "Disabled" : "Enabled"
      networkAcls = {
        defaultAction       = "Allow"
        ipRules             = []
        virtualNetworkRules = []
      }

      # No network injections for simplified deployment
      # networkInjections = [] 

      # Customer-managed encryption (if enabled)
      # Note: CMK configuration requires additional setup
    }
  }

  tags = local.common_tags

  # Simplified for initial deployment
}

# OpenAI GPT-4o deployment
resource "azurerm_cognitive_deployment" "aifoundry_deployment_gpt_4o" {
  provider = azurerm.workload_subscription

  depends_on = [
    azapi_resource.ai_foundry,
    module.networking
  ]

  name                 = "gpt-4o"
  cognitive_account_id = azapi_resource.ai_foundry.id

  sku {
    name     = local.environment_config[var.environment].openai_sku
    capacity = local.environment_config[var.environment].openai_capacity
  }

  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-05-13"
  }

  # Rate limiting (environment-dependent)
  # Content filtering enabled by default
}


# AI Foundry project
resource "azapi_resource" "ai_foundry_project" {
  provider = azapi.workload_subscription

  depends_on = [
    azapi_resource.ai_foundry,
    module.networking
  ]

  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name                      = "${var.project_name}-project-${random_string.unique.result}"
  parent_id                 = azapi_resource.ai_foundry.id
  location                  = var.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices"
    identity = {
      type = var.enable_managed_identity ? "SystemAssigned" : "None"
    }

    properties = {
      description = var.project_description
      displayName = var.project_friendly_name

      # Project-specific settings
      projectSettings = {
        enableDataCollection = local.environment_config[var.environment].enable_data_collection
        enableTelemetry      = local.environment_config[var.environment].enable_telemetry
      }
    }
  }

  response_export_values = [
    "identity.principalId",
    "properties.internalId"
  ]

  tags = local.common_tags
}

# Wait 10 seconds for the AI Foundry project system-assigned managed identity to be created and to replicate
# through Entra ID
resource "time_sleep" "wait_project_identities" {
  depends_on = [
    azapi_resource.ai_foundry_project
  ]
  create_duration = "10s"
}

# =============================================================================
# Project-level Connections (Simplified - No Cosmos DB)
# =============================================================================

# Create the AI Foundry project connection to Azure Storage Account
resource "azapi_resource" "conn_storage" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name                      = azurerm_storage_account.storage_account.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = azurerm_storage_account.storage_account.name
    properties = {
      category                    = "AzureStorageAccount"
      target                      = azurerm_storage_account.storage_account.primary_blob_endpoint
      authType                    = "AAD"
      useWorkspaceManagedIdentity = false
      isSharedToAll               = false
      sharedUserList              = []
      peRequirement               = "NotRequired"
      peStatus                    = "NotApplicable"
      metadata = {
        ApiType    = "Azure"
        ResourceId = azurerm_storage_account.storage_account.id
        location   = var.location
      }
    }
  }

  response_export_values = [
    "identity.principalId"
  ]
}

# Create the AI Foundry project connection to AI Search
resource "azapi_resource" "conn_aisearch" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name                      = azapi_resource.ai_search.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = azapi_resource.ai_search.name
    properties = {
      category                    = "CognitiveSearch"
      target                      = "https://${azapi_resource.ai_search.name}.search.windows.net/"
      authType                    = "AAD"
      useWorkspaceManagedIdentity = false
      isSharedToAll               = false
      sharedUserList              = []
      peRequirement               = "NotRequired"
      peStatus                    = "NotApplicable"
      metadata = {
        type                 = "azure_ai_search"
        ApiType              = "Azure"
        ResourceId           = azapi_resource.ai_search.id
        ApiVersion           = "2024-05-01-preview"
        DeploymentApiVersion = "2023-11-01"
        location             = var.location
      }
    }
  }

  response_export_values = [
    "identity.principalId"
  ]
}

# Create the AI Foundry project connection to AI Services (parent account)
resource "azapi_resource" "conn_ai_services" {
  provider = azapi.workload_subscription

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-04-01-preview"
  name                      = azapi_resource.ai_foundry.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = azapi_resource.ai_foundry.name
    properties = {
      category                    = "AIServices"
      target                      = azapi_resource.ai_foundry.output.properties.endpoint
      authType                    = "AAD"
      useWorkspaceManagedIdentity = false
      isSharedToAll               = false
      sharedUserList              = []
      peRequirement               = "NotRequired"
      peStatus                    = "NotApplicable"
      metadata = {
        ApiType    = "Azure"
        ResourceId = azapi_resource.ai_foundry.id
        location   = var.location
      }
    }
  }

  response_export_values = [
    "identity.principalId"
  ]
}

# RBAC Module - Simplified Role-Based Access Control (No Cosmos DB)
module "rbac" {
  source = "./modules/rbac"

  environment         = var.environment
  resource_group_name = var.resource_group_name_resources

  # AI Foundry identity information
  ai_foundry_account_name         = azapi_resource.ai_foundry.name
  ai_foundry_account_principal_id = azapi_resource.ai_foundry.output.identity.principalId
  ai_foundry_project_name         = azapi_resource.ai_foundry_project.name
  ai_foundry_project_principal_id = azapi_resource.ai_foundry_project.output.identity.principalId

  # Resource IDs for role assignments (removed Cosmos DB)
  storage_account_id    = azurerm_storage_account.storage_account.id
  storage_account_name  = azurerm_storage_account.storage_account.name
  search_service_id     = azapi_resource.ai_search.id
  search_service_name   = azapi_resource.ai_search.name
  ai_foundry_account_id = azapi_resource.ai_foundry.id
  ai_foundry_project_id = azapi_resource.ai_foundry_project.id
  key_vault_id          = try(module.security.key_vault_id, null)

  # Security features
  enable_customer_managed_keys = var.enable_customer_managed_keys
  create_key_vault             = var.enable_customer_managed_keys && var.key_vault_id == null

  # Additional Key Vault access (optional)
  additional_key_vault_administrators = []
  additional_key_vault_users          = []

  # Platform admin users and groups
  platform_admin_user_object_ids  = length(var.platform_admin_users) > 0 ? tolist(data.azuread_users.platform_admin_users[0].object_ids) : []
  platform_admin_group_object_ids = length(var.platform_admin_groups) > 0 ? tolist(data.azuread_groups.platform_admin_groups[0].object_ids) : []

  depends_on = [
    azurerm_storage_account.storage_account,
    azapi_resource.ai_search,
    azapi_resource.ai_foundry,
    azapi_resource.ai_foundry_project,
    module.security,
    time_sleep.wait_project_identities
  ]
}

# Wait for role assignments to propagate
resource "time_sleep" "wait_rbac" {
  depends_on = [
    module.rbac
  ]
  create_duration = "30s"
}
