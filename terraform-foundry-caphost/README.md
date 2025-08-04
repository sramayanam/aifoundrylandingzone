# Azure AI Foundry Infrastructure with Capability Hosts

> **Standard Agent Configuration** - Azure AI Foundry deployment with capability hosts and Standard Agent network injection

Terraform configuration for deploying Azure AI Foundry with capability hosts, enabling bring-your-own Azure resources for complete data sovereignty and security control.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                Azure AI Foundry with Capability Hosts       │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │ AI Foundry   │    │   Storage    │    │  AI Search   │   │
│  │   Hub        │    │   Account    │    │   Service    │   │
│  │ (w/ Agents)  │    │              │    │              │   │
│  └──────────────┘    └──────────────┘    └──────────────┘   │
│          │                    │                    │        │
│          ▼                    ▼                    ▼        │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │ AI Foundry   │    │   Cosmos DB  │    │   Private    │   │
│  │   Project    │    │ (Threads)    │    │  Endpoints   │   │
│  │              │    │              │    │              │   │
│  └──────────────┘    └──────────────┘    └──────────────┘   │
│          │                    │                             │
│          ▼                    ▼                             │
│  ┌──────────────┐    ┌──────────────────────────────────┐   │
│  │ Capability   │    │    Agent Subnet (Delegated)      │   │
│  │   Hosts      │    │  • Standard Agent Injection      │   │
│  │              │    │  • Microsoft.CognitiveServices   │   │
│  └──────────────┘    │  • Network Security              │   │
│                      └──────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🔍 Key Differences from NoCapabilityHosts

### ✅ **Added Features:**
- **Cosmos DB** - Thread and conversation storage
- **Agent Subnet** - Delegated subnet for Standard Agent network injection
- **Capability Hosts** - Account and project-level resource configuration
- **Enhanced RBAC** - Data plane permissions for Cosmos DB containers
- **Standard Agent Setup** - Full bring-your-own resource configuration

### ⚠️ **Important Requirements:**
- **Agent Subnet**: Must be delegated to `Microsoft.CognitiveServices/accounts`
- **Resource Recreation**: AI Foundry account must be recreated with network injection
- **New Resource Group**: Recommended to use fresh resource group (`rg-agents-secured-caphost`)
- **RBAC Timing**: Critical 60-second wait for role propagation before capability host creation

## 📋 Prerequisites

- **Azure Subscriptions**: Two subscriptions (workload and infrastructure)
- **Agent Subnet**: Pre-created subnet with delegation to `Microsoft.CognitiveServices/accounts`
- **Private Endpoints Subnet**: Separate subnet for private endpoints
- **DNS Zones**: All required private DNS zones linked to VNet
- **Permissions**: Contributor access to both subscriptions
- **Tools**: Terraform >= 1.5.0, Azure CLI

### Required Subnet Configuration

The agent subnet must be pre-configured with delegation:
```bash
# Your agent subnet should be configured with:
delegation {
  name = "Microsoft.CognitiveServices.accounts"
  service_delegation {
    name = "Microsoft.CognitiveServices/accounts"
  }
}
```

### Required Private DNS Zones

- `privatelink.cognitiveservices.azure.com`
- `privatelink.openai.azure.com` 
- `privatelink.services.ai.azure.com`
- `privatelink.blob.core.windows.net`
- `privatelink.search.windows.net`
- `privatelink.documents.azure.com` (for Cosmos DB)

## 🚀 Quick Start

1. **Clone and navigate to the repository:**
   ```bash
   git clone <repository-url>
   cd terraform-foundry-caphost
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Set up environment variables:**
   ```bash
   # Required for Azure Storage backend authentication
   export ARM_SUBSCRIPTION_ID="your-infrastructure-subscription-id"
   ```

4. **Create terraform.tfvars:**
   ```hcl
   # Core settings
   project_name = "aifoundry"
   environment  = "dev"
   location     = "eastus2"
   
   # Subscription IDs
   subscription_id_resources = "your-workload-subscription-id"
   subscription_id_infra     = "your-infrastructure-subscription-id"
   
   # Resource groups
   resource_group_name_resources = "rg-agents-secured-caphost"
   
   # Networking - BOTH subnets required
   subnet_id_private_endpoint = "/subscriptions/your-infrastructure-subscription-id/resourceGroups/rg-your-network-rg/providers/Microsoft.Network/virtualNetworks/your-vnet-name/subnets/private-endpoint-subnet"
   subnet_id_agent = "/subscriptions/your-infrastructure-subscription-id/resourceGroups/rg-your-network-rg/providers/Microsoft.Network/virtualNetworks/your-vnet-name/subnets/agent-subnet"
   
   # Private DNS zones
   dns_zone_cognitiveservices = "/subscriptions/your-infrastructure-subscription-id/resourceGroups/rg-dns-zones/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"
   dns_zone_openai           = "/subscriptions/your-infrastructure-subscription-id/resourceGroups/rg-dns-zones/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
   dns_zone_ai_services      = "/subscriptions/your-infrastructure-subscription-id/resourceGroups/rg-dns-zones/providers/Microsoft.Network/privateDnsZones/privatelink.services.ai.azure.com"
   storage_blob_dns_zone_id  = "/subscriptions/your-infrastructure-subscription-id/resourceGroups/rg-dns-zones/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
   search_dns_zone_id        = "/subscriptions/your-infrastructure-subscription-id/resourceGroups/rg-dns-zones/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net"
   cosmos_dns_zone_id        = "/subscriptions/your-infrastructure-subscription-id/resourceGroups/rg-dns-zones/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com"
   
   # Admin access
   platform_admin_users = ["admin@yourcompany.com"]
   platform_admin_groups = ["your-admin-group-object-id"]
   ```

5. **Plan and deploy:**
   ```bash
   terraform plan
   terraform apply
   ```

## 🔧 Capability Hosts Configuration

This deployment creates capability hosts at both levels:

### Account-Level Capability Host
- Provides shared defaults for all projects
- Configured with storage, search, and Cosmos DB connections

### Project-Level Capability Host  
- Overrides service defaults
- Ensures agents use your specific Azure resources
- Includes thread storage, vector storage, and file storage connections

## ⏱️ Deployment Timeline

The deployment includes critical timing for RBAC propagation:

1. **Resources Created** (0-5 minutes)
2. **Initial RBAC Assignments** (5-6 minutes) 
3. **60-Second Wait** - Critical for permission propagation
4. **Capability Hosts Creation** (6-8 minutes)
5. **Data Plane RBAC** (8-10 minutes) - Cosmos DB container permissions

## 💡 Cost Considerations

Additional costs compared to NoCapabilityHosts configuration:
- **Cosmos DB**: ~$25-50/month (depending on throughput)
- **Agent Subnet**: No additional cost
- **Enhanced RBAC**: No additional cost
- **Total Additional**: ~$25-50/month for Standard Agent capabilities

## ⚠️ Migration from NoCapabilityHosts

**Important**: You cannot modify an existing AI Foundry account to add network injection. You must:

1. Use a new resource group
2. Create fresh AI Foundry account with `networkInjections` configured
3. Migrate any existing project configurations manually
4. Update application connection strings

## 🛠 Troubleshooting

### Common Issues

**Agent subnet delegation errors**:
- Verify subnet is delegated to `Microsoft.CognitiveServices/accounts`
- Check subnet has sufficient IP addresses (minimum /28)

**Capability host creation failures**:
- Ensure 60-second RBAC wait completed
- Verify all connection resources exist
- Check connection names match resource names exactly

**Cosmos DB permission errors**:
- Data plane role assignments require capability host to exist first
- Container names follow pattern: `{project-id}-thread-message-store`

## 📚 Next Steps

After deployment:
1. **Verify capability hosts in Azure portal**
2. **Configure network security for development access:**
   - Disable AI Foundry public network access if not needed
   - Whitelist Cosmos DB with Azure service IPs for AI Foundry access
   - Add portal middleware IPs to Cosmos DB firewall for desktop development
3. **Test agent creation and thread storage**
4. **Configure monitoring and alerting**
5. **Set up backup strategies for Cosmos DB**

### 🔒 **Important Security Configuration**

**Post-deployment network hardening:**
```bash
# 1. Disable AI Foundry public access (optional)
az cognitiveservices account update \
  --name "$FOUNDRY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --public-network-access Disabled

# 2. Configure Cosmos DB firewall for development
az cosmosdb network-rule add \
  --account-name "$COSMOS_DB_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --ip-range-filter "0.0.0.0"  # Replace with your development IP ranges

# 3. Allow Azure services (required for AI Foundry)
az cosmosdb update \
  --name "$COSMOS_DB_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-virtual-network true \
  --network-acl-bypass AzureServices
```

**Development IP ranges to whitelist:**
- **Azure Portal IPs**: Check Azure Portal IP ranges for your region
- **Your office/home IPs**: Add your development machine IP ranges
- **CI/CD pipeline IPs**: If using automated deployments

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
