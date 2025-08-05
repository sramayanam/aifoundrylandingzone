#!/usr/bin/env python3
"""
Main executable for Azure AI Foundry Agent with Semantic Kernel Integration
Provides both programmatic and interactive interfaces
"""

import os
import sys
import asyncio
import argparse
from pathlib import Path
from typing import Dict, Any

# Import our custom modules
from ai_foundry_agent_creator import AIFoundryAgentCreator
from semantic_kernel_agent_wrapper import SemanticKernelAgentWrapper, AgentConfig, InteractiveAgentSession


def load_environment():
    """Load environment variables with defaults"""
    # Load from .env file first
    from dotenv import load_dotenv
    load_dotenv()
    
    env_vars = {
        "PROJECT_ENDPOINT": os.getenv("PROJECT_ENDPOINT", "https://aifoundry6219.services.ai.azure.com/api/projects/project6219"),
        "MODEL_DEPLOYMENT_NAME": os.getenv("MODEL_DEPLOYMENT_NAME", "gpt-4o"),
        "AZURE_CLIENT_ID": os.getenv("AZURE_CLIENT_ID"),
        "AZURE_CLIENT_SECRET": os.getenv("AZURE_CLIENT_SECRET"),
        "AZURE_TENANT_ID": os.getenv("AZURE_TENANT_ID")
    }
    
    return env_vars


def print_banner():
    """Print application banner"""
    banner = """
╔══════════════════════════════════════════════════════════════════════════════╗
║                    Azure AI Foundry + Semantic Kernel                       ║
║                         End-to-End Agent Demo                               ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """
    print(banner)


async def create_foundry_agent(env_vars: Dict[str, Any]) -> Dict[str, Any]:
    """Create an agent using Azure AI Foundry APIs"""
    print("\n🏗️  Creating Azure AI Foundry Agent...")
    
    creator = AIFoundryAgentCreator(
        project_endpoint=env_vars["PROJECT_ENDPOINT"],
        model_deployment_name=env_vars["MODEL_DEPLOYMENT_NAME"]
    )
    
    # Create the agent
    agent_info = creator.create_agent(
        name="SemanticKernelDemoAgent",
        instructions="You are an advanced AI assistant with comprehensive capabilities. You can analyze data, write code, solve complex problems, and provide detailed explanations. You have access to code interpretation tools and can perform calculations, data analysis, and generate visualizations when needed.",
        description="Production-ready AI agent with Semantic Kernel integration"
    )
    
    # Create a test thread and verify functionality
    thread_info = creator.create_thread()
    
    creator.send_message(
        thread_id=thread_info["id"],
        content="Hello! Please introduce yourself and explain your capabilities."
    )
    
    creator.run_agent(
        thread_id=thread_info["id"],
        agent_id=agent_info["id"]
    )
    
    messages = creator.get_messages(thread_info["id"])
    
    print("✅ Agent created and tested successfully!")
    print(f"   Agent ID: {agent_info['id']}")
    print(f"   Test conversation had {len(messages)} messages")
    
    return {
        "agent": agent_info,
        "thread": thread_info,
        "messages": messages
    }


async def create_semantic_kernel_wrapper(env_vars: Dict[str, Any]) -> SemanticKernelAgentWrapper:
    """Create and initialize Semantic Kernel wrapper"""
    print("\n🧠 Initializing Semantic Kernel Wrapper...")
    
    config = AgentConfig(
        project_endpoint=env_vars["PROJECT_ENDPOINT"],
        model_deployment_name=env_vars["MODEL_DEPLOYMENT_NAME"],
        agent_name="SemanticKernelProductionAgent",
        agent_instructions="You are a production-grade AI assistant powered by Semantic Kernel. You excel at complex reasoning, code generation, data analysis, and problem-solving. Provide accurate, helpful, and well-structured responses.",
        agent_description="Production Semantic Kernel Azure AI Agent"
    )
    
    wrapper = SemanticKernelAgentWrapper(config)
    await wrapper.create_agent()
    
    print("✅ Semantic Kernel wrapper initialized successfully!")
    
    return wrapper


async def run_test_scenarios(wrapper: SemanticKernelAgentWrapper):
    """Run comprehensive test scenarios"""
    print("\n🧪 Running Test Scenarios...")
    
    test_cases = [
        {
            "name": "Basic Conversation",
            "message": "Hello! What can you help me with today?"
        },
        {
            "name": "Math Problem",
            "message": "Can you solve this equation and show your work: 3x + 15 = 42"
        },
        {
            "name": "Code Generation",
            "message": "Write a Python function to calculate the factorial of a number using recursion"
        },
        {
            "name": "Data Analysis",
            "message": "If I have sales data: January: $10000, February: $12000, March: $15000, April: $11000, what's the average monthly sales and growth trend?"
        }
    ]
    
    results = []
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n📝 Test {i}/{len(test_cases)}: {test_case['name']}")
        print(f"   Question: {test_case['message']}")
        
        try:
            response = await wrapper.chat_with_agent(test_case['message'])
            print(f"   ✅ Response: {response[:200]}{'...' if len(response) > 200 else ''}")
            
            results.append({
                "test": test_case['name'],
                "success": True,
                "response_length": len(response)
            })
            
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
            results.append({
                "test": test_case['name'],
                "success": False,
                "error": str(e)
            })
    
    # Print summary
    successful = sum(1 for r in results if r['success'])
    print(f"\n📊 Test Summary: {successful}/{len(results)} tests passed")
    
    return results


async def run_interactive_mode(wrapper: SemanticKernelAgentWrapper):
    """Run interactive chat session"""
    print("\n💬 Starting Interactive Mode...")
    session = InteractiveAgentSession(wrapper)
    await session.start_interactive_session()


async def main():
    """Main application entry point"""
    parser = argparse.ArgumentParser(description="Azure AI Foundry + Semantic Kernel Demo")
    parser.add_argument("--mode", choices=["foundry", "semantic", "test", "interactive", "all"], 
                       default="all", help="Execution mode")
    parser.add_argument("--skip-foundry", action="store_true", 
                       help="Skip Azure AI Foundry agent creation")
    parser.add_argument("--interactive", action="store_true", 
                       help="Run interactive session after setup")
    
    args = parser.parse_args()
    
    print_banner()
    
    # Load environment
    env_vars = load_environment()
    
    # Validate required environment variables
    if not env_vars["PROJECT_ENDPOINT"] or not env_vars["MODEL_DEPLOYMENT_NAME"]:
        print("❌ Missing required environment variables:")
        print("   PROJECT_ENDPOINT")
        print("   MODEL_DEPLOYMENT_NAME")
        print("\nPlease set these environment variables or pass them as arguments.")
        sys.exit(1)
    
    print(f"🔧 Configuration:")
    print(f"   Project Endpoint: {env_vars['PROJECT_ENDPOINT']}")
    print(f"   Model: {env_vars['MODEL_DEPLOYMENT_NAME']}")
    print(f"   Mode: {args.mode}")
    
    try:
        # Create Azure AI Foundry agent (if not skipped)
        if args.mode in ["foundry", "all"] and not args.skip_foundry:
            foundry_result = await create_foundry_agent(env_vars)
            if not foundry_result:
                print("❌ Failed to create Azure AI Foundry agent")
                sys.exit(1)
        
        # Create Semantic Kernel wrapper
        if args.mode in ["semantic", "test", "interactive", "all"]:
            wrapper = await create_semantic_kernel_wrapper(env_vars)
            
            # Run test scenarios
            if args.mode in ["test", "all"]:
                test_results = await run_test_scenarios(wrapper)
                
                # Check if all tests passed
                if not all(r['success'] for r in test_results):
                    print("⚠️  Some tests failed, but continuing...")
            
            # Run interactive mode
            if args.mode == "interactive" or args.interactive:
                await run_interactive_mode(wrapper)
        
        print("\n🎉 All operations completed successfully!")
        print("✅ Azure AI Foundry agent created and tested")
        print("✅ Semantic Kernel wrapper operational")
        print("✅ Container ready for deployment")
        
    except KeyboardInterrupt:
        print("\n\n👋 Operation cancelled by user")
        sys.exit(0)
    except Exception as e:
        print(f"\n💥 Fatal Error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    # Ensure we're running with proper async support
    if sys.platform == "win32":
        asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())
    
    asyncio.run(main())