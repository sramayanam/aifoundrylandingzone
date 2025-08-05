#!/usr/bin/env python3
"""
Demo Test Script - Tests components that don't require network access
"""

import os
import sys
import asyncio
from pathlib import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

from ai_foundry_agent_creator import AIFoundryAgentCreator
from semantic_kernel_agent_wrapper import AgentConfig, SemanticKernelAgentWrapper


def test_environment_loading():
    """Test that environment variables are loaded correctly"""
    print("🔧 Testing environment configuration...")
    
    # Load from .env file
    from dotenv import load_dotenv
    load_dotenv()
    
    project_endpoint = os.getenv("PROJECT_ENDPOINT")
    model_name = os.getenv("MODEL_DEPLOYMENT_NAME")
    client_id = os.getenv("AZURE_CLIENT_ID")
    
    print(f"   Project Endpoint: {project_endpoint}")
    print(f"   Model: {model_name}")
    print(f"   Client ID: {client_id[:8]}..." if client_id else "   Client ID: Not set")
    
    if project_endpoint and model_name:
        print("✅ Environment configuration looks good")
        return True
    else:
        print("❌ Missing required environment variables")
        return False


def test_class_initialization():
    """Test that our classes can be initialized without network calls"""
    print("\n🏗️  Testing class initialization...")
    
    try:
        # Test AIFoundryAgentCreator initialization
        creator = AIFoundryAgentCreator(
            project_endpoint="https://test.endpoint.com",
            model_deployment_name="gpt-4o-mini"
        )
        print("✅ AIFoundryAgentCreator initialized successfully")
        
        # Test AgentConfig
        config = AgentConfig(
            project_endpoint="https://test.endpoint.com",
            model_deployment_name="gpt-4o-mini",
            agent_name="TestAgent",
            agent_instructions="Test instructions",
            agent_description="Test description"
        )
        print("✅ AgentConfig created successfully")
        
        # Test SemanticKernelAgentWrapper initialization (without creating agent)
        wrapper = SemanticKernelAgentWrapper(config)
        print("✅ SemanticKernelAgentWrapper initialized successfully")
        
        return True
        
    except Exception as e:
        print(f"❌ Class initialization failed: {str(e)}")
        return False


def test_imports():
    """Test that all required modules can be imported"""
    print("\n📦 Testing imports...")
    
    try:
        import azure.ai.projects
        print("✅ azure.ai.projects imported")
        
        import azure.identity
        print("✅ azure.identity imported")
        
        import semantic_kernel
        print("✅ semantic_kernel imported")
        
        from semantic_kernel.agents import AzureAIAgent
        print("✅ AzureAIAgent imported")
        
        import azure.ai.agents.models
        print("✅ azure.ai.agents.models imported")
        
        return True
        
    except ImportError as e:
        print(f"❌ Import failed: {str(e)}")
        return False


def test_agent_config_validation():
    """Test agent configuration validation"""
    print("\n🔍 Testing configuration validation...")
    
    try:
        # Test valid configuration
        config = AgentConfig(
            project_endpoint="https://test.endpoint.com/api/projects/test",
            model_deployment_name="gpt-4o-mini",
            agent_name="ValidAgent",
            agent_instructions="You are a helpful assistant.",
            agent_description="Test agent for validation"
        )
        
        # Check that all fields are set correctly
        assert config.project_endpoint == "https://test.endpoint.com/api/projects/test"
        assert config.model_deployment_name == "gpt-4o-mini"
        assert config.agent_name == "ValidAgent"
        assert config.agent_instructions == "You are a helpful assistant."
        assert config.agent_description == "Test agent for validation"
        
        print("✅ Configuration validation passed")
        return True
        
    except Exception as e:
        print(f"❌ Configuration validation failed: {str(e)}")
        return False


def test_semantic_kernel_initialization():
    """Test Semantic Kernel initialization"""
    print("\n🧠 Testing Semantic Kernel initialization...")
    
    try:
        config = AgentConfig(
            project_endpoint="https://test.endpoint.com/api/projects/test",
            model_deployment_name="gpt-4o-mini"
        )
        
        # This should initialize the kernel without making network calls
        wrapper = SemanticKernelAgentWrapper(config)
        
        # Check that kernel was initialized
        if wrapper.kernel is not None:
            print("✅ Semantic Kernel initialized successfully")
            return True
        else:
            print("❌ Semantic Kernel not initialized")
            return False
            
    except Exception as e:
        print(f"❌ Semantic Kernel initialization failed: {str(e)}")
        return False


def main():
    """Run all demo tests"""
    print("🧪 Azure AI Foundry + Semantic Kernel Demo Tests")
    print("=" * 60)
    
    tests = [
        ("Environment Loading", test_environment_loading),
        ("Module Imports", test_imports),
        ("Class Initialization", test_class_initialization),
        ("Configuration Validation", test_agent_config_validation),
        ("Semantic Kernel Init", test_semantic_kernel_initialization),
    ]
    
    results = []
    
    for test_name, test_func in tests:
        try:
            success = test_func()
            results.append((test_name, success))
        except Exception as e:
            print(f"💥 {test_name} crashed: {str(e)}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 TEST SUMMARY")
    print("=" * 60)
    
    passed = sum(1 for _, success in results if success)
    total = len(results)
    
    for test_name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{test_name:<25} {status}")
    
    print(f"\nOverall Result: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! The system is ready for deployment.")
        print("\n🚀 Next steps:")
        print("   1. Ensure your Azure AI Foundry resource has network access")
        print("   2. Test with: python main.py --mode foundry")
        print("   3. Run interactive mode: python main.py --mode interactive")
        print("   4. Deploy container: docker run -it --env-file .env azure-ai-semantic-kernel-demo")
    else:
        print("\n⚠️  Some tests failed. Please review the issues above.")
    
    return passed == total


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)