terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.38"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.15"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "aaaorgtfstorage"
    container_name       = "tfstatecaphost"
    key                  = "terraform-foundry-caphost.tfstate"
    use_azuread_auth     = true
    # subscription_id is set via ARM_SUBSCRIPTION_ID environment variable
  }
}

provider "azurerm" {
  features {
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id_resources
}

provider "azurerm" {
  alias           = "infra"
  subscription_id = var.subscription_id_infra
  features {}
}

provider "azapi" {
  subscription_id = var.subscription_id_resources
}

provider "time" {}

# ============================================================================
# DATA SOURCES
# ============================================================================

data "azurerm_client_config" "current" {}


data "azurerm_subnet" "private_endpoint" {
  name                 = split("/", var.subnet_id_private_endpoint)[10]
  virtual_network_name = split("/", var.subnet_id_private_endpoint)[8]
  resource_group_name  = split("/", var.subnet_id_private_endpoint)[4]
}

data "azurerm_subnet" "agent" {
  name                 = split("/", var.subnet_id_agent)[10]
  virtual_network_name = split("/", var.subnet_id_agent)[8]
  resource_group_name  = split("/", var.subnet_id_agent)[4]
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name_resources
}

# ============================================================================
# SHARED INFRASTRUCTURE
# ============================================================================

resource "azurerm_user_assigned_identity" "main" {
  name                = "${local.resource_prefix}-identity"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  tags = local.common_tags
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.resource_prefix}-law"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = local.log_analytics_config.sku
  retention_in_days   = local.log_analytics_config.retention_in_days

  tags = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                = "${local.resource_prefix}-ai"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  application_type    = local.app_insights_config.application_type
  workspace_id        = azurerm_log_analytics_workspace.main.id

  tags = local.common_tags
}

# Storage Account for files
resource "azurerm_storage_account" "main" {
  name                = local.validated_storage_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  account_tier             = local.storage_config.account_tier
  account_replication_type = local.storage_config.account_replication_type
  account_kind             = local.storage_config.account_kind

  # Enable Microsoft network routing
  routing {
    publish_internet_endpoints  = false
    publish_microsoft_endpoints = true
    choice                      = "MicrosoftRouting"
  }

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = local.storage_config.cors_allowed_methods
      allowed_origins    = local.storage_config.cors_allowed_origins
      exposed_headers    = ["*"]
      max_age_in_seconds = 1800
    }
  }

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }

  timeouts {
    create = "10m"
    read   = "5m"
    update = "10m"
    delete = "10m"
  }

  tags = local.common_tags
}

# AI Search service for vector storage
resource "azapi_resource" "ai_search" {
  type                      = "Microsoft.Search/searchServices@2023-11-01"
  name                      = "${local.resource_prefix}-search"
  parent_id                 = data.azurerm_resource_group.main.id
  location                  = data.azurerm_resource_group.main.location
  schema_validation_enabled = true

  body = {
    sku = {
      name = "standard"
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      # Search-specific properties
      replicaCount   = 1
      partitionCount = 1
      hostingMode    = "default"
      semanticSearch = "disabled"

      # Identity-related controls
      disableLocalAuth = false
      authOptions = {
        aadOrApiKey = {
          aadAuthFailureMode = "http401WithBearerChallenge"
        }
      }

      # Networking-related controls
      publicNetworkAccess = "disabled"
      networkRuleSet = {
        ipRules = []
      }
    }
  }

  tags = local.common_tags
}

# Cosmos DB account for thread storage
resource "azurerm_cosmosdb_account" "main" {
  name                = "${local.resource_prefix}-cosmos"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = data.azurerm_resource_group.main.location
    failover_priority = 0
  }

  public_network_access_enabled     = false
  is_virtual_network_filter_enabled = true

  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
    storage_redundancy  = "Geo"
  }

  tags = local.common_tags
}

# Cosmos DB database
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = local.cosmos_config.database_name
  resource_group_name = data.azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

# AI Foundry resource (Cognitive Services account with project management)
resource "azapi_resource" "ai_foundry" {
  type                      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name                      = local.resource_prefix
  parent_id                 = data.azurerm_resource_group.main.id
  location                  = data.azurerm_resource_group.main.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices"
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      # Support both Entra ID and API Key authentication
      disableLocalAuth = false

      # Specifies that this is an AI Foundry resource
      allowProjectManagement = true

      # Set custom subdomain name for DNS names
      customSubDomainName = local.resource_prefix

      # Network-related controls
      publicNetworkAccess = "Enabled"
      networkAcls = {
        defaultAction = "Allow"
      }

      # Enable VNet injection for Standard Agents
      # Temporarily disabled due to Azure ML RP issues
      networkInjections = [
        {
           scenario                   = "agent"
           subnetArmId                = local.network_config.agent_subnet_id
           useMicrosoftManagedNetwork = false
         }
       ]
    }
  }

  depends_on = [
    azurerm_storage_account.main,
    azurerm_cosmosdb_account.main,
    azapi_resource.ai_search
  ]

  response_export_values = [
    "identity.principalId"
  ]

  tags = local.common_tags
}

# Azure OpenAI model deployments
resource "azurerm_cognitive_deployment" "gpt4o" {
  name                 = local.openai_models.gpt4o.name
  cognitive_account_id = azapi_resource.ai_foundry.id

  model {
    format  = "OpenAI"
    name    = local.openai_models.gpt4o.name
    version = local.openai_models.gpt4o.version
  }

  sku {
    name     = "Standard"
    capacity = local.openai_models.gpt4o.capacity
  }

  depends_on = [azapi_resource.ai_foundry]
}

resource "azurerm_cognitive_deployment" "text_embedding" {
  name                 = local.openai_models.embedding.name
  cognitive_account_id = azapi_resource.ai_foundry.id

  model {
    format  = "OpenAI"
    name    = local.openai_models.embedding.name
    version = local.openai_models.embedding.version
  }

  sku {
    name     = "Standard"
    capacity = local.openai_models.embedding.capacity
  }

  depends_on = [azapi_resource.ai_foundry]
}

# AI Foundry Project
resource "azapi_resource" "ai_foundry_project" {
  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name                      = "${local.resource_prefix}-project"
  parent_id                 = azapi_resource.ai_foundry.id
  location                  = data.azurerm_resource_group.main.location
  schema_validation_enabled = false

  body = {
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      displayName = "${var.project_name} Project"
      description = "AI Foundry project with network secured deployed Agent"
    }
  }

  response_export_values = [
    "identity.principalId",
    "properties.internalId"
  ]

  depends_on = [azapi_resource.ai_foundry]

  tags = local.common_tags
}

# Wait for project identity to propagate
resource "time_sleep" "wait_project_identities" {
  depends_on      = [azapi_resource.ai_foundry_project]
  create_duration = "10s"
}

# Project connection to Cosmos DB
resource "azapi_resource" "conn_cosmosdb" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = azurerm_cosmosdb_account.main.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  body = {
    name = azurerm_cosmosdb_account.main.name
    properties = {
      category = "CosmosDb"
      target   = azurerm_cosmosdb_account.main.endpoint
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = azurerm_cosmosdb_account.main.id
        location   = data.azurerm_resource_group.main.location
      }
    }
  }

  depends_on = [azapi_resource.ai_foundry_project]
}

# Project connection to Storage Account
resource "azapi_resource" "conn_storage" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = azurerm_storage_account.main.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  body = {
    name = azurerm_storage_account.main.name
    properties = {
      category = "AzureStorageAccount"
      target   = azurerm_storage_account.main.primary_blob_endpoint
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = azurerm_storage_account.main.id
        location   = data.azurerm_resource_group.main.location
      }
    }
  }

  response_export_values = ["identity.principalId"]
  depends_on             = [azapi_resource.ai_foundry_project]
}

# Project connection to AI Search
resource "azapi_resource" "conn_aisearch" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = azapi_resource.ai_search.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  body = {
    name = azapi_resource.ai_search.name
    properties = {
      category = "CognitiveSearch"
      target   = "https://${azapi_resource.ai_search.name}.search.windows.net"
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ApiVersion = "2025-05-01-preview"
        ResourceId = azapi_resource.ai_search.id
        location   = data.azurerm_resource_group.main.location
      }
    }
  }

  response_export_values = ["identity.principalId"]
  depends_on             = [azapi_resource.ai_foundry_project]
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Random string for environment suffix to prevent conflicts
resource "random_string" "env_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Project RBAC assignments
resource "azurerm_role_assignment" "cosmosdb_operator_ai_foundry_project" {
  depends_on = [time_sleep.wait_project_identities]

  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${data.azurerm_resource_group.main.name}cosmosdboperator")
  scope                = azurerm_cosmosdb_account.main.id
  role_definition_name = "Cosmos DB Operator"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
}

# Cosmos DB Data Contributor for AI Foundry Project (data plane access)
resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_data_contributor_project" {
  depends_on = [time_sleep.wait_project_identities]

  name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}cosmosdbdatacontributor")
  resource_group_name = data.azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  role_definition_id  = "${azurerm_cosmosdb_account.main.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azapi_resource.ai_foundry_project.output.identity.principalId
  scope               = azurerm_cosmosdb_account.main.id
}

# Cosmos DB Data Contributor for AI Foundry Account (data plane access)
resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_data_contributor_foundry" {
  depends_on = [azapi_resource.ai_foundry]

  name                = uuidv5("dns", "${azapi_resource.ai_foundry.name}${azapi_resource.ai_foundry.output.identity.principalId}cosmosdbdatacontributor")
  resource_group_name = data.azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  role_definition_id  = "${azurerm_cosmosdb_account.main.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azapi_resource.ai_foundry.output.identity.principalId
  scope               = azurerm_cosmosdb_account.main.id
}

resource "azurerm_role_assignment" "storage_blob_data_contributor_ai_foundry_project" {
  depends_on = [time_sleep.wait_project_identities]

  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${azurerm_storage_account.main.name}storageblobdatacontributor")
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
}

resource "azurerm_role_assignment" "search_index_data_contributor_ai_foundry_project" {
  depends_on = [time_sleep.wait_project_identities]

  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${azapi_resource.ai_search.name}searchindexdatacontributor")
  scope                = azapi_resource.ai_search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
}

resource "azurerm_role_assignment" "search_service_contributor_ai_foundry_project" {
  depends_on = [time_sleep.wait_project_identities]

  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${azapi_resource.ai_search.name}searchservicecontributor")
  scope                = azapi_resource.ai_search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
}

# Wait for RBAC propagation before creating capability hosts
resource "time_sleep" "rbac_propagation" {
  depends_on = [
    azurerm_role_assignment.cosmosdb_operator_ai_foundry_project,
    azurerm_role_assignment.storage_blob_data_contributor_ai_foundry_project,
    azurerm_role_assignment.search_index_data_contributor_ai_foundry_project,
    azurerm_role_assignment.search_service_contributor_ai_foundry_project
  ]

  create_duration = "120s"
}

# Project capability host
resource "azapi_resource" "project_capability_host" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview"
  name                      = "default-project-caphost"
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  body = {
    properties = {
      capabilityHostKind = "Agents"
      vectorStoreConnections = [
        azapi_resource.ai_search.name
      ]
      storageConnections = [
        azurerm_storage_account.main.name
      ]
      threadStorageConnections = [
        azurerm_cosmosdb_account.main.name
      ]
    }
  }

  depends_on = [
    azapi_resource.conn_aisearch,
    azapi_resource.conn_cosmosdb,
    azapi_resource.conn_storage,
    time_sleep.rbac_propagation
  ]
}
