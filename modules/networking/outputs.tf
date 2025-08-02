# =============================================================================
# Networking Module Outputs (Simplified - No Cosmos DB, No Agent Subnet)
# =============================================================================

# Private Endpoint IDs
output "storage_blob_private_endpoint_id" {
  description = "The ID of the Storage Account Blob private endpoint."
  value       = length(azurerm_private_endpoint.storage_blob) > 0 ? azurerm_private_endpoint.storage_blob[0].id : null
}

output "storage_file_private_endpoint_id" {
  description = "The ID of the Storage Account File private endpoint."
  value       = length(azurerm_private_endpoint.storage_file) > 0 ? azurerm_private_endpoint.storage_file[0].id : null
}

output "search_private_endpoint_id" {
  description = "The ID of the AI Search private endpoint."
  value       = length(azurerm_private_endpoint.search) > 0 ? azurerm_private_endpoint.search[0].id : null
}

output "ai_foundry_private_endpoint_id" {
  description = "The ID of the AI Foundry private endpoint."
  value       = length(azurerm_private_endpoint.ai_foundry) > 0 ? azurerm_private_endpoint.ai_foundry[0].id : null
}

# Private Endpoint IP Addresses
output "storage_blob_private_endpoint_ip" {
  description = "The private IP address of the Storage Account Blob private endpoint."
  value = length(azurerm_private_endpoint.storage_blob) > 0 ? (
    length(azurerm_private_endpoint.storage_blob[0].private_service_connection) > 0 ?
    azurerm_private_endpoint.storage_blob[0].private_service_connection[0].private_ip_address : null
  ) : null
}

output "storage_file_private_endpoint_ip" {
  description = "The private IP address of the Storage Account File private endpoint."
  value = length(azurerm_private_endpoint.storage_file) > 0 ? (
    length(azurerm_private_endpoint.storage_file[0].private_service_connection) > 0 ?
    azurerm_private_endpoint.storage_file[0].private_service_connection[0].private_ip_address : null
  ) : null
}

output "search_private_endpoint_ip" {
  description = "The private IP address of the AI Search private endpoint."
  value = length(azurerm_private_endpoint.search) > 0 ? (
    length(azurerm_private_endpoint.search[0].private_service_connection) > 0 ?
    azurerm_private_endpoint.search[0].private_service_connection[0].private_ip_address : null
  ) : null
}

output "ai_foundry_private_endpoint_ip" {
  description = "The private IP address of the AI Foundry private endpoint."
  value = length(azurerm_private_endpoint.ai_foundry) > 0 ? (
    length(azurerm_private_endpoint.ai_foundry[0].private_service_connection) > 0 ?
    azurerm_private_endpoint.ai_foundry[0].private_service_connection[0].private_ip_address : null
  ) : null
}

# Network Security Group
output "private_endpoints_nsg_id" {
  description = "The ID of the Network Security Group for private endpoints."
  value       = length(azurerm_network_security_group.private_endpoints) > 0 ? azurerm_network_security_group.private_endpoints[0].id : null
}

# Route Table
output "private_endpoints_route_table_id" {
  description = "The ID of the route table for private endpoints."
  value       = length(azurerm_route_table.private_endpoints) > 0 ? azurerm_route_table.private_endpoints[0].id : null
}

# Private Endpoint FQDNs (useful for DNS configuration)
output "storage_blob_private_endpoint_fqdn" {
  description = "The FQDN for the Storage Account Blob private endpoint."
  value = length(azurerm_private_endpoint.storage_blob) > 0 ? (
    length(azurerm_private_endpoint.storage_blob[0].custom_dns_configs) > 0 ?
    azurerm_private_endpoint.storage_blob[0].custom_dns_configs[0].fqdn : null
  ) : null
}

output "storage_file_private_endpoint_fqdn" {
  description = "The FQDN for the Storage Account File private endpoint."
  value = length(azurerm_private_endpoint.storage_file) > 0 ? (
    length(azurerm_private_endpoint.storage_file[0].custom_dns_configs) > 0 ?
    azurerm_private_endpoint.storage_file[0].custom_dns_configs[0].fqdn : null
  ) : null
}

output "search_private_endpoint_fqdn" {
  description = "The FQDN for the AI Search private endpoint."
  value = length(azurerm_private_endpoint.search) > 0 ? (
    length(azurerm_private_endpoint.search[0].custom_dns_configs) > 0 ?
    azurerm_private_endpoint.search[0].custom_dns_configs[0].fqdn : null
  ) : null
}

output "ai_foundry_private_endpoint_fqdn" {
  description = "The FQDN for the AI Foundry private endpoint."
  value = length(azurerm_private_endpoint.ai_foundry) > 0 ? (
    length(azurerm_private_endpoint.ai_foundry[0].custom_dns_configs) > 0 ?
    azurerm_private_endpoint.ai_foundry[0].custom_dns_configs[0].fqdn : null
  ) : null
}

# Summary output for all created private endpoints
output "private_endpoints_summary" {
  description = "Summary of all created private endpoints."
  value = {
    storage_blob = length(azurerm_private_endpoint.storage_blob) > 0 ? {
      id   = azurerm_private_endpoint.storage_blob[0].id
      name = azurerm_private_endpoint.storage_blob[0].name
      ip   = length(azurerm_private_endpoint.storage_blob[0].private_service_connection) > 0 ? azurerm_private_endpoint.storage_blob[0].private_service_connection[0].private_ip_address : null
    } : null

    storage_file = length(azurerm_private_endpoint.storage_file) > 0 ? {
      id   = azurerm_private_endpoint.storage_file[0].id
      name = azurerm_private_endpoint.storage_file[0].name
      ip   = length(azurerm_private_endpoint.storage_file[0].private_service_connection) > 0 ? azurerm_private_endpoint.storage_file[0].private_service_connection[0].private_ip_address : null
    } : null

    search = length(azurerm_private_endpoint.search) > 0 ? {
      id   = azurerm_private_endpoint.search[0].id
      name = azurerm_private_endpoint.search[0].name
      ip   = length(azurerm_private_endpoint.search[0].private_service_connection) > 0 ? azurerm_private_endpoint.search[0].private_service_connection[0].private_ip_address : null
    } : null

    ai_foundry = length(azurerm_private_endpoint.ai_foundry) > 0 ? {
      id   = azurerm_private_endpoint.ai_foundry[0].id
      name = azurerm_private_endpoint.ai_foundry[0].name
      ip   = length(azurerm_private_endpoint.ai_foundry[0].private_service_connection) > 0 ? azurerm_private_endpoint.ai_foundry[0].private_service_connection[0].private_ip_address : null
    } : null
  }
}
