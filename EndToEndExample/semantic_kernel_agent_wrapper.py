#!/usr/bin/env python3
"""
Semantic Kernel Azure AI Agent Wrapper
Wraps Azure AI Foundry agents with Semantic Kernel functionality
"""

import os
import asyncio
from typing import Optional, Dict, Any, List
from dataclasses import dataclass

from semantic_kernel import Kernel
from semantic_kernel.agents import AzureAIAgent
# Azure AI Inference connection handled by AzureAIAgent
from semantic_kernel.contents.chat_message_content import ChatMessageContent
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential


@dataclass
class AgentConfig:
    """Configuration for the Semantic Kernel Azure AI Agent"""
    project_endpoint: str
    model_deployment_name: str
    agent_name: str = "SemanticKernelAgent"
    agent_instructions: str = "You are a helpful AI assistant."
    agent_description: str = "Semantic Kernel wrapped Azure AI agent"


class SemanticKernelAgentWrapper:
    """
    Wrapper class that integrates Azure AI Foundry agents with Semantic Kernel
    """
    
    def __init__(self, config: AgentConfig):
        """
        Initialize the Semantic Kernel Agent Wrapper
        
        Args:
            config: AgentConfig containing connection and agent details
        """
        self.config = config
        self.kernel = None
        self.agent = None
        self.client = None
        self._initialize_kernel()
    
    def _initialize_kernel(self):
        """Initialize the Semantic Kernel with Azure AI services"""
        try:
            # Create the kernel
            self.kernel = Kernel()
            
            # Note: We'll let the AzureAIAgent handle the AI service connection
            # since it already has access to the AI Project Client
            print("✅ Semantic Kernel initialized successfully")
            
        except Exception as e:
            print(f"❌ Error initializing Semantic Kernel: {str(e)}")
            raise
    
    async def create_agent(self) -> AzureAIAgent:
        """
        Create an Azure AI agent wrapped with Semantic Kernel
        
        Returns:
            AzureAIAgent instance
        """
        try:
            # Create AI Project Client using the async version
            from azure.ai.projects.aio import AIProjectClient as AsyncAIProjectClient
            
            self.client = AsyncAIProjectClient(
                endpoint=self.config.project_endpoint,
                credential=DefaultAzureCredential()
            )
            
            # First create the agent using Azure AI Projects API
            from azure.ai.agents.models import CodeInterpreterTool
            
            agent_definition = await self.client.agents.create_agent(
                model=self.config.model_deployment_name,
                name=self.config.agent_name,
                instructions=self.config.agent_instructions,
                tools=CodeInterpreterTool().definitions,
                description=self.config.agent_description
            )
            
            print(f"✅ Azure AI Agent '{agent_definition.name}' created with ID: {agent_definition.id}")
            
            # Now wrap it with Semantic Kernel
            self.agent = AzureAIAgent(
                client=self.client,
                definition=agent_definition,
                kernel=self.kernel
            )
            
            print(f"✅ Agent wrapped with Semantic Kernel integration")
            return self.agent
            
        except Exception as e:
            print(f"❌ Error creating agent: {str(e)}")
            raise
    
    async def chat_with_agent(self, message: str) -> str:
        """
        Send a message to the agent and get a response
        
        Args:
            message: User message to send to the agent
            
        Returns:
            Agent's response as a string
        """
        if not self.agent:
            raise RuntimeError("Agent not created. Call create_agent() first.")
        
        try:
            # Use invoke method which returns an async generator
            messages = []
            async for message_chunk in self.agent.invoke(message):
                messages.append(message_chunk)
            
            if messages:
                # Find the last assistant message
                for msg in reversed(messages):
                    if hasattr(msg, 'role') and msg.role == 'assistant':
                        if hasattr(msg, 'content'):
                            content = msg.content
                            if isinstance(content, str):
                                return content
                            elif hasattr(content, 'text'):
                                return str(content.text)
                            elif hasattr(content, 'value'):
                                return str(content.value)
                            else:
                                return str(content)
                        else:
                            return str(msg)
                
                # If no assistant message found, return info about what we got
                return f"Received {len(messages)} messages but no assistant response found"
            
            return "No response received from agent"
                
        except Exception as e:
            print(f"❌ Error getting agent response: {str(e)}")
            raise
    
    async def stream_chat_with_agent(self, message: str):
        """
        Stream a conversation with the agent
        
        Args:
            message: User message to send to the agent
            
        Yields:
            Streaming response chunks
        """
        if not self.agent:
            raise RuntimeError("Agent not created. Call create_agent() first.")
        
        try:
            async for chunk in self.agent.invoke_stream(message):
                yield chunk
                
        except Exception as e:
            print(f"❌ Error streaming agent response: {str(e)}")
            raise
    
    async def invoke_agent(self, message: str) -> List[ChatMessageContent]:
        """
        Invoke the agent and get full message history
        
        Args:
            message: User message to send to the agent
            
        Returns:
            List of ChatMessageContent objects
        """
        if not self.agent:
            raise RuntimeError("Agent not created. Call create_agent() first.")
        
        try:
            response = await self.agent.invoke(message)
            return response
            
        except Exception as e:
            print(f"❌ Error invoking agent: {str(e)}")
            raise
    
    def get_agent_info(self) -> Dict[str, Any]:
        """
        Get information about the current agent
        
        Returns:
            Dictionary containing agent information
        """
        if not self.agent:
            return {"error": "No agent created"}
        
        return {
            "name": self.config.agent_name,
            "model": self.config.model_deployment_name,
            "instructions": self.config.agent_instructions,
            "description": self.config.agent_description,
            "endpoint": self.config.project_endpoint
        }


class InteractiveAgentSession:
    """Interactive session manager for the Semantic Kernel Agent"""
    
    def __init__(self, wrapper: SemanticKernelAgentWrapper):
        self.wrapper = wrapper
        
    async def start_interactive_session(self):
        """Start an interactive chat session with the agent"""
        print("\n🤖 Starting interactive session with Semantic Kernel Agent")
        print("💡 Type 'quit', 'exit', or 'bye' to end the session")
        print("💡 Type 'info' to see agent information")
        print("💡 Type 'stream' before your message to get streaming responses")
        print("-" * 60)
        
        while True:
            try:
                user_input = input("\n👤 You: ").strip()
                
                if user_input.lower() in ['quit', 'exit', 'bye']:
                    print("👋 Goodbye!")
                    break
                
                if user_input.lower() == 'info':
                    info = self.wrapper.get_agent_info()
                    print(f"\n📋 Agent Info:")
                    for key, value in info.items():
                        print(f"   {key}: {value}")
                    continue
                
                if user_input.lower().startswith('stream '):
                    message = user_input[7:]  # Remove 'stream ' prefix
                    print(f"\n🤖 Agent (streaming): ", end="", flush=True)
                    
                    full_response = ""
                    async for chunk in self.wrapper.stream_chat_with_agent(message):
                        if chunk and hasattr(chunk, 'content'):
                            content = str(chunk.content)
                            print(content, end="", flush=True)
                            full_response += content
                    print()  # New line after streaming
                    continue
                
                if user_input:
                    print(f"\n🤖 Agent: ", end="", flush=True)
                    response = await self.wrapper.chat_with_agent(user_input)
                    print(response)
                
            except KeyboardInterrupt:
                print("\n\n👋 Session interrupted. Goodbye!")
                break
            except Exception as e:
                print(f"\n❌ Error: {str(e)}")


async def main():
    """Main function to demonstrate the Semantic Kernel Agent Wrapper"""
    
    # Configuration
    config = AgentConfig(
        project_endpoint=os.getenv("PROJECT_ENDPOINT", "https://aifoundry6219.services.ai.azure.com/api/projects/project6219"),
        model_deployment_name=os.getenv("MODEL_DEPLOYMENT_NAME", "gpt-4o-mini"),
        agent_name="SemanticKernelDemoAgent",
        agent_instructions="You are a helpful AI assistant with advanced reasoning capabilities. You can analyze data, write code, solve problems, and provide detailed explanations. Be thorough but concise in your responses.",
        agent_description="Advanced AI agent integrated with Semantic Kernel for enhanced functionality"
    )
    
    print("🚀 Initializing Semantic Kernel Azure AI Agent Wrapper...")
    
    try:
        # Create the wrapper
        wrapper = SemanticKernelAgentWrapper(config)
        
        # Create the agent
        agent = await wrapper.create_agent()
        
        # Test basic functionality
        print("\n🧪 Testing basic agent functionality...")
        test_message = "Hello! Can you tell me about your capabilities and then solve this simple math problem: What is 15 * 7 + 23?"
        response = await wrapper.chat_with_agent(test_message)
        print(f"👤 Test Question: {test_message}")
        print(f"🤖 Agent Response: {response}")
        
        # Start interactive session
        session = InteractiveAgentSession(wrapper)
        await session.start_interactive_session()
        
    except Exception as e:
        print(f"💥 Error: {str(e)}")
        return False
    
    return True


if __name__ == "__main__":
    asyncio.run(main())