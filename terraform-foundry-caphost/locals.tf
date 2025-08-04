locals {
  # Common tags for all resources
  common_tags = merge({
    Environment    = var.environment
    Project        = var.project_name
    ManagedBy      = "terraform"
    Purpose        = "ai-foundry-caphost"
    Repository     = "terraform-foundry-agent"
    DeploymentType = "caphost"
    CreatedBy      = data.azurerm_client_config.current.object_id
  }, var.tags)

  # Naming conventions with 4-letter random suffix for environment
  resource_prefix = "${var.project_name}-${var.environment}${random_string.env_suffix.result}"

  # Random suffix for unique naming (used in storage accounts, etc.)
  name_suffix = random_string.suffix.result

  # Network configuration
  network_config = {
    agent_subnet_id            = data.azurerm_subnet.agent.id
    private_endpoint_subnet_id = data.azurerm_subnet.private_endpoint.id
  }


  # OpenAI model configurations
  openai_models = {
    gpt4o = {
      name     = "gpt-4o"
      version  = "2024-08-06"
      capacity = 20
    }
    embedding = {
      name     = "text-embedding-3-small"
      version  = "1"
      capacity = 20
    }
  }

  # Cosmos DB configuration
  cosmos_config = {
    database_name = "ThreadData"
    containers = {
      threads  = "threads"
      messages = "messages"
      metadata = "metadata"
    }
  }

  # Storage configuration with environment-based settings
  storage_config = {
    account_tier             = "Standard"
    account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
    account_kind             = "StorageV2"

    # CORS for AI Foundry access
    cors_allowed_origins = [
      "https://ml.azure.com",
      "https://mlworkspace.azure.ai",
      "https://ai.azure.com"
    ]
    cors_allowed_methods = [
      "DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"
    ]
  }

  # Validated resource names
  validated_storage_name = substr(replace(lower("${var.project_name}st${var.environment}${local.name_suffix}"), "/[^a-z0-9]/", ""), 0, 24)




  # Application Insights configuration
  app_insights_config = {
    application_type = "web"
  }

  # Log Analytics configuration
  log_analytics_config = {
    sku               = "PerGB2018"
    retention_in_days = 30
  }
}
