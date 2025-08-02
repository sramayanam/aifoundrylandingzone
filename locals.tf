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

}

# Dynamic project ID GUID calculation (only available after project creation)
locals {
}
