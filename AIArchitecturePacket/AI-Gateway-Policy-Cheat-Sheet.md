# AI Gateway Policy Cheat Sheet

This comprehensive cheat sheet consolidates all the policy snippets from the AI-Gateway repository, categorized by functionality and use cases.

## 🔐 Authentication Policies

### Azure AD Token Validation
```xml
<validate-azure-ad-token tenant-id="{tenant-id}">
    <client-application-ids>
        <application-id>{client-application-id}</application-id>
    </client-application-ids>
</validate-azure-ad-token>
```
**Use Case**: Authenticate users against Azure AD  
**Key Parameters**: `tenant-id`, `client-application-ids`

### JWT Token Validation (OpenID Connect)
```xml
<validate-jwt header-name="Authorization" 
              failed-validation-httpcode="401" 
              failed-validation-error-message="Unauthorized. Access token is missing or invalid." 
              output-token-variable-name="jwt-token">
    <openid-config url="https://login.microsoftonline.com/common/.well-known/openid-configuration" />
    <audiences>
        <audience>https://azure-api.net/authorization-manager</audience>
    </audiences>
</validate-jwt>
```
**Use Case**: OAuth2/OpenID Connect authentication flows  
**Key Parameters**: `header-name`, `audiences`, `openid-config url`

### Managed Identity Authentication
```xml
<authentication-managed-identity resource="https://cognitiveservices.azure.com" 
                                 output-token-variable-name="managed-id-access-token" 
                                 ignore-error="false" />
<set-header name="Authorization" exists-action="override">
    <value>@("Bearer " + (string)context.Variables["managed-id-access-token"])</value>
</set-header>
```
**Use Case**: Authenticate with Azure services without storing credentials  
**Key Parameters**: `resource`, `output-token-variable-name`

### External Authorization Context
```xml
<get-authorization-context provider-id="@(context.Request.Headers["providerId"][0])" 
                          authorization-id="@(context.Request.Headers["authorizationId"][0])" 
                          context-variable-name="auth-context" 
                          identity-type="managed" 
                          ignore-error="false" />
<set-header name="Authorization" exists-action="override">
    <value>@("Bearer " + ((Authorization)context.Variables.GetValueOrDefault("auth-context"))?.AccessToken)</value>
</set-header>
```
**Use Case**: Complex authorization scenarios with external providers  
**Key Parameters**: `provider-id`, `authorization-id`, `identity-type`

### Custom Token Decryption
```xml
<set-variable name="accessToken" value="@{
    // Custom token extraction and validation logic
    if(context.Request.Headers.ContainsKey("Authorization"))
    {
        return context.Request.Headers["Authorization"].FirstOrDefault()?.Split(' ').Last();
    }
    return "";
}" />
<set-variable name="decryptedSessionId" value="@{
    byte[] inBytes = Convert.FromBase64String((string)context.Variables["accessToken"]);
    byte[] IV = Convert.FromBase64String((string)context.Variables["IV"]);
    byte[] key = Convert.FromBase64String((string)context.Variables["key"]);
    byte[] decryptedBytes = inBytes.Decrypt("Aes", key, IV);
    return Encoding.UTF8.GetString(decryptedBytes);
}" />
```
**Use Case**: Custom authentication schemes requiring encryption  
**Key Parameters**: EncryptionKey, EncryptionIV (from named values)

## 🚦 Rate Limiting Policies

### Azure OpenAI Token Rate Limiting
```xml
<azure-openai-token-limit counter-key="@(context.Subscription.Id)" 
                         tokens-per-minute="500" 
                         estimate-prompt-tokens="false" 
                         remaining-tokens-variable-name="remainingTokens" />
```
**Use Case**: Control OpenAI API costs and usage by token consumption  
**Key Parameters**: `counter-key`, `tokens-per-minute`, `estimate-prompt-tokens`

### Generic LLM Token Limiting
```xml
<llm-token-limit counter-key="@(context.Subscription.Id)" 
                tokens-per-minute="1000" 
                estimate-prompt-tokens="false" 
                remaining-tokens-variable-name="remainingTokens" />
```
**Use Case**: Rate limiting for non-OpenAI LLM providers  
**Key Parameters**: `counter-key`, `tokens-per-minute`

### IP-based Rate Limiting
```xml
<rate-limit-by-key calls="5" 
                   renewal-period="30" 
                   counter-key="@(context.Request.IpAddress)" 
                   remaining-calls-variable-name="remainingCallsPerIP" />
```
**Use Case**: Prevent abuse from specific IP addresses  
**Key Parameters**: `calls`, `renewal-period`, `counter-key`

## 🛡️ Content Safety & Filtering

### Content Safety Filtering
```xml
<llm-content-safety backend-id="content-safety-backend" shield-prompt="true">
    <categories output-type="EightSeverityLevels">
        <category name="SelfHarm" threshold="4" />
        <category name="Hate" threshold="4" />
        <category name="Violence" threshold="4" />
        <category name="Sexual" threshold="4" />
    </categories>
    <blocklists>
        <id>blocklist1</id>            
    </blocklists>   
</llm-content-safety>
```
**Use Case**: Filter harmful content using Azure Content Safety  
**Key Parameters**: `threshold` values, `shield-prompt`, `blocklists`

## 🔄 Backend Routing & Load Balancing

### Simple Backend Routing
```xml
<set-backend-service backend-id="{backend-id}" />
```
**Use Case**: Simple routing to a specific backend  
**Key Parameters**: `backend-id`

### Advanced Load Balancing with Circuit Breaking
```xml
<cache-lookup-value key="listBackends" variable-name="listBackends" />
<choose>
    <when condition="@(context.Variables.ContainsKey("listBackends") == false)">
        <set-variable name="loadBalancerConfig" value="{{openai-lb-config}}" />
        <set-variable name="listBackends" value="@{
            var openAIConfig = JArray.Parse((string)context.Variables["loadBalancerConfig"]);
            JArray backends = new JArray();
            foreach (JObject config in openAIConfig)
            {
                backends.Add(new JObject()
                {
                    { "name", config.GetValue("name").ToString() },
                    { "priority", config.GetValue("priority").Value<int>() },
                    { "weight", config.GetValue("weight").Value<int>() },
                    { "isThrottling", false },
                    { "retryAfter", DateTime.MinValue }
                });
            }
            return backends;
        }" />
        <cache-store-value key="listBackends" value="@((JArray)context.Variables["listBackends"])" duration="60" />
    </when>
</choose>
```
**Use Case**: High-availability scenarios with multiple backends and failover  
**Key Parameters**: `loadBalancerConfig` (named value), `priority`, `weight`

### Model-Based Routing
```xml
<set-variable name="deployment" value="@(context.Request.MatchedParameters.ContainsKey("deployment-id") 
           ? context.Request.MatchedParameters["deployment-id"] 
           : string.Empty)" />
<set-variable name="model" value="@( ((JObject)context.Variables["reqBody"])
              .Property("model")?.Value?.ToString() 
              ?? string.Empty)" />
<choose>
    <when condition="@( ((string)context.Variables["requestedModel"]) == "gpt-4.1")">
        <set-backend-service backend-id="foundry1" />
    </when>
    <when condition="@( ((string)context.Variables["requestedModel"]) == "gpt-4.1-mini" 
                 || ((string)context.Variables["requestedModel"]) == "gpt-4.1-nano")">
        <set-backend-service backend-id="foundry2" />
    </when>
    <otherwise>
        <set-backend-service backend-id="default-backend" />
    </otherwise>
</choose>
```
**Use Case**: Route requests based on AI model selection  
**Key Parameters**: `deployment-id`, model name from request body

## ↩️ Retry & Resilience Policies

### Basic Retry with Condition
```xml
<retry count="2" 
       interval="0" 
       first-fast-retry="true" 
       condition="@(context.Response.StatusCode == 429 || (context.Response.StatusCode == 503 && !context.Response.StatusReason.Contains("Backend pool") && !context.Response.StatusReason.Contains("is temporarily unavailable")))">
    <forward-request buffer-request-body="true" />
</retry>
```
**Use Case**: Resilience against transient failures (throttling, server errors)  
**Key Parameters**: `count`, `interval`, `condition` logic

### Advanced Retry in Load Balancer
```xml
<retry condition="@(context.Response != null && (context.Response.StatusCode == 429 || context.Response.StatusCode >= 500) && (Convert.ToInt32(context.Variables["remainingBackends"]) > 0))" 
       count="50" 
       interval="0">
    <!-- Dynamic backend selection logic -->
    <set-variable name="selectedBackend" value="@{
        // Backend selection with priority and weight logic
        var backends = (JArray)context.Variables["listBackends"];
        return SelectNextAvailableBackend(backends);
    }" />
    <forward-request buffer-request-body="true" />
</retry>
```
**Use Case**: Sophisticated load balancing with dynamic backend failover  
**Key Parameters**: Dynamic condition based on remaining backends, high retry count

## 📊 Metrics & Monitoring

### Azure OpenAI Token Metrics
```xml
<azure-openai-emit-token-metric namespace="openai">
    <dimension name="Subscription ID" value="@(context.Subscription.Id)" />
    <dimension name="Client IP" value="@(context.Request.IpAddress)" />
    <dimension name="API ID" value="@(context.Api.Id)" />
    <dimension name="User ID" value="@(context.Request.Headers.GetValueOrDefault("x-user-id", "N/A"))" />
</azure-openai-emit-token-metric>
```
**Use Case**: Detailed metrics for OpenAI usage tracking and cost analysis  
**Key Parameters**: `namespace`, custom `dimension` values

### Generic LLM Metrics
```xml
<llm-emit-token-metric namespace="llm">
    <dimension name="Client IP" value="@(context.Request.IpAddress)" />
    <dimension name="API ID" value="@(context.Api.Id)" />
    <dimension name="Model" value="@(context.Variables.GetValueOrDefault("model", "unknown"))" />
</llm-emit-token-metric>
```
**Use Case**: Token usage tracking for non-OpenAI LLMs  
**Key Parameters**: `namespace`, custom dimensions

### Custom Application Tracing
```xml
<trace source="Weather MCP" severity="information">
    <message>Weather MCP trace info</message>
    <metadata name="agent-id" value="@(context.Request.Headers.GetValueOrDefault("agent-id", "n/a"))" />
    <metadata name="user-id" value="@(((Jwt)context.Variables["jwt-token"]).Claims.GetValueOrDefault("email", "n/a"))" />
</trace>
```
**Use Case**: Debugging and application monitoring  
**Key Parameters**: `source`, `severity`, custom `metadata`

## 🔄 Response Transformation & Caching

### Streaming Detection
```xml
<choose>
    <when condition="@(context.Request.Body.As<JObject>(true)["stream"] != null && context.Request.Body.As<JObject>(true)["stream"].Type != JTokenType.Null)">
        <set-variable name="isStream" value="@{
            var content = (context.Request.Body?.As<JObject>(true));
            string streamValue = content["stream"].ToString();
            return streamValue;
        }" />
        <set-header name="Accept" exists-action="override">
            <value>text/event-stream</value>
        </set-header>
    </when>
</choose>
```
**Use Case**: Handle streaming AI responses appropriately  
**Key Parameters**: Stream detection logic, appropriate headers

### Semantic Caching
```xml
<!-- In inbound -->
<azure-openai-semantic-cache-lookup score-threshold="0.8" 
                                    embeddings-backend-id="embeddings-backend" 
                                    embeddings-backend-auth="system-assigned" />
<!-- In outbound -->
<azure-openai-semantic-cache-store duration="120" />
```
**Use Case**: Cache AI responses based on semantic similarity to reduce costs  
**Key Parameters**: `score-threshold`, `duration`, `embeddings-backend-id`

### Mock Response Generation
```xml
<return-response>
    <set-status code="200" />
    <set-header name="Content-Type" exists-action="override">
        <value>application/json</value>
    </set-header>
    <set-body>@{
        var random = new Random();
        var names = new[] { "Smartphone", "Tablet", "Laptop", "Smartwatch" };
        var category = context.Request.MatchedParameters.GetValueOrDefault("category", "electronics");
        return new JObject(
            new JProperty("name", names[random.Next(names.Length)]),
            new JProperty("category", category),
            new JProperty("price", random.Next(100, 2000))
        ).ToString();
    }</set-body>
</return-response>
```
**Use Case**: Testing and development with dynamic mock data  
**Key Parameters**: Dynamic response generation logic

## 🌐 CORS & Security Headers

### CORS Configuration
```xml
<cors allow-credentials="true">
    <allowed-origins>
        <origin>https://ai.azure.com/</origin>
        <origin>https://localhost:3000</origin>
    </allowed-origins>
    <allowed-methods>
        <method>GET</method>
        <method>POST</method>
        <method>PUT</method>
        <method>DELETE</method>
        <method>OPTIONS</method>
    </allowed-methods>
    <allowed-headers>
        <header>Authorization</header>
        <header>Content-Type</header>
        <header>x-user-id</header>
    </allowed-headers>
    <expose-headers>
        <header>x-remaining-tokens</header>
        <header>x-rate-limit-remaining</header>
    </expose-headers>
</cors>
```
**Use Case**: Browser-based applications accessing the API  
**Key Parameters**: `allowed-origins`, `methods`, `headers`

## ❌ Error Handling

### Generic Error Response
```xml
<on-error>
    <base />
    <choose>
        <when condition="@(context.Response.StatusCode == 503)">
            <return-response>
                <set-status code="503" reason="Service Unavailable" />
                <set-header name="Content-Type" exists-action="override">
                    <value>application/json</value>
                </set-header>
                <set-body>{
                    "error": "service_unavailable",
                    "error_description": "The service is temporarily unavailable. Please try again later."
                }</set-body>
            </return-response>
        </when>
    </choose>
</on-error>
```
**Use Case**: Standardize error responses and hide backend details  
**Key Parameters**: Status code conditions, error message format

### Authentication Error Responses
```xml
<choose>
    <when condition="@((string)context.Variables["accessToken"] == "")">
        <return-response>
            <set-status code="401" reason="Unauthorized" />
            <set-header name="WWW-Authenticate" exists-action="override">
                <value>Bearer realm="AI-Gateway"</value>
            </set-header>
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>{
                "error": "unauthorized",
                "error_description": "No access token provided or token is invalid"
            }</set-body>
        </return-response>
    </when>
</choose>
```
**Use Case**: Detailed authentication error responses  
**Key Parameters**: Custom error messages and status codes

## 🏗️ Request/Response Body Manipulation

### Request Body Transformation
```xml
<set-body>@{
    var originalBody = context.Request.Body.As<JObject>(preserveContent: true);
    
    // Add system message
    if (originalBody["messages"] is JArray messages)
    {
        var systemMessage = new JObject();
        systemMessage["role"] = "system";
        systemMessage["content"] = "You are a helpful AI assistant.";
        
        ((JArray)originalBody["messages"]).Insert(0, systemMessage);
    }
    
    // Set default parameters
    if (originalBody["temperature"] == null)
        originalBody["temperature"] = 0.7;
        
    if (originalBody["max_tokens"] == null)
        originalBody["max_tokens"] = 1000;
    
    return originalBody.ToString();
}</set-body>
```
**Use Case**: Modify requests before forwarding to backend  
**Key Parameters**: Custom transformation logic

### Response Body Filtering
```xml
<set-body>@{
    var responseBody = context.Response.Body.As<JObject>(preserveContent: true);
    
    // Remove sensitive information
    if (responseBody["usage"] != null)
    {
        responseBody["usage"]["internal_cost"] = null;
    }
    
    // Add custom headers to response body
    responseBody["api_version"] = "2024-02-15-preview";
    responseBody["gateway_version"] = "1.0.0";
    
    return responseBody.ToString();
}</set-body>
```
**Use Case**: Filter or enhance responses before returning to client  
**Key Parameters**: Response modification logic

## 📋 Common Patterns Summary

### 1. Multi-Model AI Gateway Pattern
Combines model routing + authentication + rate limiting + metrics for comprehensive AI service management.

### 2. High-Availability Load Balancing Pattern
Uses circuit breaking + retry logic + backend health tracking for resilient service delivery.

### 3. Cost-Optimized AI Pattern
Implements semantic caching + token rate limiting + detailed metrics for cost control.

### 4. Secure AI Gateway Pattern
Combines multiple authentication methods + content filtering + CORS + error handling for secure AI access.

### 5. Development-to-Production Pattern
Uses mock responses for development + conditional routing + comprehensive monitoring for smooth deployments.

## 🛠️ Best Practices

1. **Always use caching** for expensive operations (backend lists, embeddings)
2. **Implement proper error handling** at both policy and global levels  
3. **Use named values** for configuration instead of hardcoded values
4. **Add comprehensive logging** for debugging and monitoring
5. **Implement retry logic** with exponential backoff for resilience
6. **Use semantic caching** for AI responses to reduce costs
7. **Apply rate limiting** at multiple levels (IP, subscription, token-based)
8. **Validate and sanitize** all inputs before processing
9. **Use managed identities** instead of storing secrets
10. **Monitor token usage** closely for cost optimization

## 📚 Variable Naming Conventions

- `context.Variables["jwt-token"]` - Validated JWT token
- `context.Variables["managed-id-access-token"]` - Managed identity token
- `context.Variables["listBackends"]` - Available backends array
- `context.Variables["selectedBackend"]` - Currently selected backend
- `context.Variables["remainingTokens"]` - Token rate limit remaining
- `context.Variables["isStream"]` - Streaming request indicator
- `context.Variables["reqBody"]` - Request body as JObject
- `context.Variables["model"]` - Requested AI model name
- `context.Variables["accessToken"]` - Extracted access token

---

*This cheat sheet covers the comprehensive policy patterns found across 52 policy.xml files in the AI-Gateway repository, providing reusable snippets for building robust AI gateway solutions.*