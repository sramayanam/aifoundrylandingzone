# Azure AI Foundry + Semantic Kernel Integration

This project demonstrates an end-to-end example of creating an AI agent using Azure AI Foundry programmatically and wrapping it with Semantic Kernel for enhanced functionality.

## Features

- 🏗️ **Programmatic Agent Creation**: Create Azure AI Foundry agents via Python APIs
- 🧠 **Semantic Kernel Integration**: Wrap agents with Semantic Kernel for advanced functionality
- 🐳 **Containerized Deployment**: Ready-to-deploy Docker container
- 🧪 **Comprehensive Testing**: Built-in test scenarios and validation
- 💬 **Interactive Mode**: Chat interface for testing and demonstration

## Architecture

```
┌─────────────────────┐    ┌──────────────────────┐    ┌─────────────────┐
│   Main Application  │    │  Semantic Kernel     │    │  Azure AI       │
│                     │───▶│  Wrapper             │───▶│  Foundry        │
│   - CLI Interface   │    │                      │    │                 │
│   - Test Scenarios  │    │  - Agent Management  │    │  - Agent APIs   │
│   - Interactive     │    │  - Chat Interface    │    │  - Model        │
└─────────────────────┘    │  - Streaming         │    │    Deployment   │
                           └──────────────────────┘    └─────────────────┘
```

## Prerequisites

- Python 3.11+
- Docker (for containerization)
- Azure subscription with AI Foundry access
- Azure CLI (for authentication)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd BuildAgent

# Copy environment template
cp .env.example .env
# Edit .env with your Azure AI Foundry details
```

### 2. Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
python main.py --mode all --interactive
```

### 3. Container Deployment

```bash
# Build container
docker build -t azure-ai-semantic-kernel-demo .

# Run container
docker run -it --env-file .env azure-ai-semantic-kernel-demo

# Run specific mode
docker run -it --env-file .env azure-ai-semantic-kernel-demo python main.py --mode interactive
```

## Usage Modes

### All Modes (Default)
```bash
python main.py --mode all
```
Runs complete pipeline: creates Foundry agent, initializes Semantic Kernel, runs tests.

### Azure AI Foundry Only
```bash
python main.py --mode foundry
```
Creates and tests Azure AI Foundry agent only.

### Semantic Kernel Only
```bash
python main.py --mode semantic --skip-foundry
```
Initializes Semantic Kernel wrapper without creating new Foundry agent.

### Test Mode
```bash
python main.py --mode test
```
Runs comprehensive test scenarios.

### Interactive Mode
```bash
python main.py --mode interactive
```
Starts interactive chat session with the agent.

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_ENDPOINT` | Azure AI Foundry project endpoint | Required |
| `MODEL_DEPLOYMENT_NAME` | Model deployment name | `gpt-4o-mini` |
| `AZURE_CLIENT_ID` | Azure service principal ID | Optional |
| `AZURE_CLIENT_SECRET` | Azure service principal secret | Optional |
| `AZURE_TENANT_ID` | Azure tenant ID | Optional |

### Agent Configuration

The agent can be customized by modifying the `AgentConfig` in `main.py`:

```python
config = AgentConfig(
    project_endpoint=env_vars["PROJECT_ENDPOINT"],
    model_deployment_name=env_vars["MODEL_DEPLOYMENT_NAME"],
    agent_name="YourCustomAgent",
    agent_instructions="Your custom instructions...",
    agent_description="Your agent description"
)
```

## File Structure

```
BuildAgent/
├── ai_foundry_agent_creator.py    # Azure AI Foundry agent creation
├── semantic_kernel_agent_wrapper.py # Semantic Kernel integration
├── main.py                        # Main application entry point
├── requirements.txt               # Python dependencies
├── Dockerfile                     # Container configuration
├── .dockerignore                  # Docker ignore patterns
├── .env.example                   # Environment template
└── README.md                      # This file
```

## Key Components

### AIFoundryAgentCreator
- Creates agents in Azure AI Foundry programmatically
- Manages threads and conversations
- Handles tool integration (Code Interpreter, etc.)

### SemanticKernelAgentWrapper
- Wraps Azure AI agents with Semantic Kernel
- Provides enhanced functionality and extensibility
- Supports streaming and async operations

### InteractiveAgentSession
- Interactive chat interface
- Command handling (quit, info, stream)
- Real-time conversation management

## Authentication

The application supports multiple authentication methods:

1. **Default Azure Credential** (Recommended)
   - Uses Azure CLI login: `az login`
   - Automatically handled by `DefaultAzureCredential`

2. **Service Principal**
   - Set `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`
   - Useful for production deployments

3. **Managed Identity**
   - Automatically used when running in Azure environments

## Testing

### Automated Tests
```bash
python main.py --mode test
```

Runs predefined test scenarios:
- Basic conversation
- Mathematical problem solving
- Code generation
- Data analysis

### Manual Testing
```bash
python main.py --mode interactive
```

Interactive commands:
- `info` - Display agent information
- `stream <message>` - Get streaming response
- `quit/exit/bye` - End session

## Deployment

### Local Container
```bash
docker build -t azure-ai-demo .
docker run -it --env-file .env azure-ai-demo
```

### Azure Container Instances
```bash
az container create \
  --resource-group myResourceGroup \
  --name azure-ai-demo \
  --image azure-ai-demo \
  --environment-variables \
    PROJECT_ENDPOINT=$PROJECT_ENDPOINT \
    MODEL_DEPLOYMENT_NAME=$MODEL_DEPLOYMENT_NAME
```

### Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-ai-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-ai-demo
  template:
    metadata:
      labels:
        app: azure-ai-demo
    spec:
      containers:
      - name: azure-ai-demo
        image: azure-ai-demo:latest
        env:
        - name: PROJECT_ENDPOINT
          value: "your-endpoint"
        - name: MODEL_DEPLOYMENT_NAME
          value: "gpt-4o-mini"
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```
   az login
   az account set --subscription <subscription-id>
   ```

2. **Module Import Errors**
   ```bash
   pip install --upgrade -r requirements.txt
   ```

3. **Container Build Issues**
   ```bash
   docker system prune -a
   docker build --no-cache -t azure-ai-demo .
   ```

### Debug Mode
```bash
python main.py --mode test --verbose
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## References

- [Azure AI Foundry Documentation](https://learn.microsoft.com/en-us/azure/ai-foundry/)
- [Semantic Kernel Documentation](https://learn.microsoft.com/en-us/semantic-kernel/)
- [Azure AI Foundry Python SDK](https://pypi.org/project/azure-ai-projects/)
- [Semantic Kernel Python](https://github.com/microsoft/semantic-kernel/tree/main/python)