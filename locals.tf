# =============================================================================
# Local Values and Computed Configuration (Simplified)
# =============================================================================

locals {
  # Resource naming convention: {project}-{env}-{random}-{type}
  # Shortened to ensure resource names stay within Azure limits
  # Max length with aifoundry-prod-1234 = 18 chars before suffix
  env_short       = var.environment == "staging" ? "stg" : (var.environment == "production" ? "prod" : var.environment)
  resource_prefix = "${var.project_name}-${local.env_short}-${random_string.unique.result}"

  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Environment     = var.environment
    Project         = var.project_name
    ProjectFriendly = var.project_friendly_name
    ManagedBy       = "Terraform"
    CreatedDate     = formatdate("YYYY-MM-DD", timestamp())
    Repository      = "terraform-foundry-agent-simplified"
    DeploymentType  = "NoCapabilityHosts"
  })

  # Resource names using consistent naming convention (simplified)
  resource_names = {
    # Core AI services
    ai_foundry_account = "${local.resource_prefix}-foundry"
    ai_foundry_project = "${local.resource_prefix}-project"

    # Storage and data services (no Cosmos DB)
    storage_account = replace("${local.resource_prefix}storage", "-", "") # Storage accounts can't have hyphens
    search_service  = "${local.resource_prefix}-search"

    # Security and monitoring
    key_vault     = "${local.resource_prefix}-kv"
    log_analytics = "${local.resource_prefix}-logs"
    app_insights  = "${local.resource_prefix}-insights"

    # Private endpoints (no Cosmos DB)
    pe_storage  = "${local.resource_prefix}-pe-storage"
    pe_search   = "${local.resource_prefix}-pe-search"
    pe_foundry  = "${local.resource_prefix}-pe-foundry"
    pe_keyvault = "${local.resource_prefix}-pe-kv"
  }

  # Environment-specific configurations (simplified without Cosmos DB settings)
  environment_config = {
    dev = {
      storage_tier                     = "Standard"
      storage_replication              = "LRS"
      search_sku                       = "basic"
      search_replicas                  = 1
      search_partitions                = 1
      backup_enabled                   = false
      zone_redundancy_enabled          = false
      enable_alerts                    = false
      log_retention_days               = 30
      daily_quota_gb                   = 1
      openai_sku                       = "GlobalStandard"
      openai_capacity                  = 1
      enable_content_filtering         = false
      disable_local_auth               = false
      search_hosting_mode              = "default"
      semantic_search                  = "disabled"
      enable_infrastructure_encryption = false
      storage_availability_threshold   = 90
      search_query_rate_threshold      = 5
      security_level                   = "basic"
      key_vault_sku                    = "standard"
      key_vault_retention_days         = 30
      estimated_monthly_cost           = 150
      backup_type                      = "Periodic"
      backup_storage_redundancy        = "Local"
      additional_regions               = []
      enable_data_collection           = false
      enable_telemetry                 = false
    }
    staging = {
      storage_tier                     = "Standard"
      storage_replication              = "ZRS"
      search_sku                       = "standard"
      search_replicas                  = 1
      search_partitions                = 1
      backup_enabled                   = true
      zone_redundancy_enabled          = false
      enable_alerts                    = true
      log_retention_days               = 90
      daily_quota_gb                   = 5
      openai_sku                       = "GlobalStandard"
      openai_capacity                  = 2
      enable_content_filtering         = true
      disable_local_auth               = false
      search_hosting_mode              = "default"
      semantic_search                  = "disabled"
      enable_infrastructure_encryption = false
      storage_availability_threshold   = 95
      search_query_rate_threshold      = 8
      security_level                   = "basic"
      key_vault_sku                    = "standard"
      key_vault_retention_days         = 60
      estimated_monthly_cost           = 400
      backup_type                      = "Periodic"
      backup_storage_redundancy        = "Zone"
      additional_regions               = []
      enable_data_collection           = true
      enable_telemetry                 = true
    }
    prod = {
      storage_tier                     = "Standard"
      storage_replication              = "GZRS"
      search_sku                       = "standard"
      search_replicas                  = 2
      search_partitions                = 1
      backup_enabled                   = true
      zone_redundancy_enabled          = true
      enable_alerts                    = true
      log_retention_days               = 365
      daily_quota_gb                   = 10
      openai_sku                       = "GlobalStandard"
      openai_capacity                  = 5
      enable_content_filtering         = true
      disable_local_auth               = true
      search_hosting_mode              = "highDensity"
      semantic_search                  = "standard"
      enable_infrastructure_encryption = true
      storage_availability_threshold   = 99
      search_query_rate_threshold      = 15
      security_level                   = "basic"
      key_vault_sku                    = "premium"
      key_vault_retention_days         = 90
      estimated_monthly_cost           = 800
      backup_type                      = "Continuous"
      backup_storage_redundancy        = "Geo"
      additional_regions = [
        { location = "westus2", failover_priority = 1, zone_redundant = true }
      ]
      enable_data_collection = true
      enable_telemetry       = true
    }
  }

  # Current environment configuration
  current_env = local.environment_config[var.environment]

  # Network configuration (simplified without Cosmos DB)
  network_config = {
    dns_zones = {
      cognitive_services = var.dns_zone_cognitiveservices
      openai             = var.dns_zone_openai
      ai_services        = var.dns_zone_ai_services
      storage_blob       = var.storage_blob_dns_zone_id
      search             = var.search_dns_zone_id
    }

    private_endpoint_config = {
      storage = {
        subresource_names = ["blob"]
        dns_zones         = [var.storage_blob_dns_zone_id]
      }
      search = {
        subresource_names = ["searchService"]
        dns_zones         = [var.search_dns_zone_id]
      }
      foundry = {
        subresource_names = ["account"]
        dns_zones = [
          var.dns_zone_cognitiveservices,
          var.dns_zone_openai,
          var.dns_zone_ai_services
        ]
      }
    }
  }

  # Security configuration (simplified)
  security_config = {
    # Storage account security settings
    storage_security = {
      min_tls_version                 = "TLS1_2"
      shared_access_key_enabled       = false
      allow_nested_items_to_be_public = false
      public_network_access_enabled   = false
      default_action                  = "Deny"
      bypass                          = ["AzureServices"]
    }

    # AI Search security settings
    search_security = {
      public_network_access = "disabled"
      disable_local_auth    = false
      auth_options = {
        aad_or_api_key = {
          aad_auth_failure_mode = "http401WithBearerChallenge"
        }
      }
    }
  }

  # Monitoring and alerting configuration (simplified)
  monitoring_config = {
    diagnostic_settings = {
      enabled = var.enable_diagnostic_settings
      categories = [
        "AuditEvent",
        "RequestResponse",
        "AllMetrics"
      ]
      retention_days = local.current_env.log_retention_days
    }

    alerts = {
      enabled           = var.enable_alerts || local.current_env.enable_alerts
      action_group_name = "${local.resource_prefix}-alerts"
      rules = {
        high_error_rate = {
          name        = "High Error Rate"
          description = "Alert when error rate exceeds threshold"
          threshold   = 10
        }
        low_availability = {
          name        = "Low Availability"
          description = "Alert when availability drops below threshold"
          threshold   = 95
        }
        high_latency = {
          name        = "High Latency"
          description = "Alert when response time exceeds threshold"
          threshold   = 5000
        }
      }
    }
  }

  # Backup configuration (simplified without Cosmos DB)
  backup_config = {
    storage_backup = {
      soft_delete_enabled           = var.enable_soft_delete
      soft_delete_retention_days    = var.soft_delete_retention_days
      versioning_enabled            = var.enable_versioning
      point_in_time_restore_enabled = var.enable_point_in_time_restore
      point_in_time_restore_days    = var.point_in_time_restore_days
    }
  }

  # Role assignments for managed identities (simplified)
  rbac_assignments = {
    project_roles = [
      {
        scope = "storage_account"
        role  = "Storage Blob Data Contributor"
      },
      {
        scope = "search_service"
        role  = "Search Index Data Contributor"
      },
      {
        scope = "search_service"
        role  = "Search Service Contributor"
      }
    ]
  }

  # Validation rules (simplified)
  validation = {
    # Ensure environment-specific settings are properly configured
    environment_valid = contains(["dev", "staging", "prod"], var.environment)

    # Validate DNS zone configuration (without Cosmos DB)
    dns_zones_configured = alltrue([
      var.dns_zone_cognitiveservices != "",
      var.dns_zone_openai != "",
      var.dns_zone_ai_services != "",
      var.storage_blob_dns_zone_id != "",
      var.search_dns_zone_id != ""
    ])

    # Validate subnet configuration (only private endpoint subnet)
    subnets_configured = var.subnet_id_private_endpoint != ""
  }

  # Feature flags based on environment and configuration
  features = {
    enable_private_endpoints     = var.enable_private_endpoints
    enable_managed_identity      = var.enable_managed_identity
    enable_customer_managed_keys = var.enable_customer_managed_keys && var.key_vault_id != null
    enable_zone_redundancy       = local.current_env.zone_redundancy_enabled
    enable_backup                = local.current_env.backup_enabled
    enable_monitoring            = var.enable_diagnostic_settings
    enable_alerts                = var.enable_alerts || local.current_env.enable_alerts
  }

  # API versions for consistency
  api_versions = {
    cognitive_services = "2025-04-01-preview"
    search_services    = "2024-06-01-preview"
    storage_accounts   = "2023-01-01"
    private_endpoints  = "2023-04-01"
    private_dns        = "2020-06-01"
  }
}

# Dynamic project ID GUID calculation (only available after project creation)
locals {
  # This will be calculated after the AI Foundry project is created
  project_id_guid = can(azapi_resource.ai_foundry_project.output.properties.internalId) ? (
    "${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 0, 8)}-${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 8, 4)}-${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 12, 4)}-${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 16, 4)}-${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 20, 12)}"
  ) : "pending"
}
