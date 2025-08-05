#!/usr/bin/env python3
"""
Azure AI Foundry Agent Creator
Programmatically creates an AI agent using Azure AI Foundry APIs
"""

import os
import asyncio
from typing import Optional
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.agents.models import CodeInterpreterTool, AzureAISearchTool, BingGroundingTool


class AIFoundryAgentCreator:
    """Creates and manages AI agents in Azure AI Foundry"""
    
    def __init__(self, project_endpoint: str, model_deployment_name: str):
        """
        Initialize the AI Foundry Agent Creator
        
        Args:
            project_endpoint: Azure AI Foundry project endpoint
            model_deployment_name: Name of the deployed model
        """
        self.project_endpoint = project_endpoint
        self.model_deployment_name = model_deployment_name
        self.credential = DefaultAzureCredential()
        self.client = AIProjectClient(
            endpoint=self.project_endpoint,
            credential=self.credential
        )
        
    def create_agent(
        self, 
        name: str, 
        instructions: str,
        tools: Optional[list] = None,
        description: Optional[str] = None
    ) -> dict:
        """
        Create an AI agent in Azure AI Foundry
        
        Args:
            name: Agent name
            instructions: System instructions for the agent
            tools: List of tools to enable for the agent
            description: Optional description of the agent
            
        Returns:
            Dictionary containing agent details
        """
        try:
            # Default tools if none specified
            if tools is None:
                tools = CodeInterpreterTool().definitions
            
            # Create the agent
            agent = self.client.agents.create_agent(
                model=self.model_deployment_name,
                name=name,
                instructions=instructions,
                tools=tools,
                description=description or f"AI Agent: {name}"
            )
            
            print(f"✅ Successfully created agent '{name}' with ID: {agent.id}")
            return {
                "id": agent.id,
                "name": agent.name,
                "instructions": agent.instructions,
                "model": agent.model,
                "tools": agent.tools,
                "created_at": agent.created_at
            }
            
        except Exception as e:
            print(f"❌ Error creating agent: {str(e)}")
            raise
    
    def create_thread(self) -> dict:
        """
        Create a conversation thread
        
        Returns:
            Dictionary containing thread details
        """
        try:
            thread = self.client.agents.threads.create()
            print(f"✅ Created thread with ID: {thread.id}")
            return {"id": thread.id, "created_at": thread.created_at}
        except Exception as e:
            print(f"❌ Error creating thread: {str(e)}")
            raise
    
    def send_message(self, thread_id: str, content: str, role: str = "user") -> dict:
        """
        Send a message to a thread
        
        Args:
            thread_id: Thread identifier
            content: Message content
            role: Message role (user, assistant)
            
        Returns:
            Dictionary containing message details
        """
        try:
            message = self.client.agents.messages.create(
                thread_id=thread_id,
                role=role,
                content=content
            )
            print(f"✅ Message sent to thread {thread_id}")
            return {
                "id": message.id,
                "thread_id": message.thread_id,
                "role": message.role,
                "content": message.content,
                "created_at": message.created_at
            }
        except Exception as e:
            print(f"❌ Error sending message: {str(e)}")
            raise
    
    def run_agent(self, thread_id: str, agent_id: str) -> dict:
        """
        Run the agent on a thread
        
        Args:
            thread_id: Thread identifier
            agent_id: Agent identifier
            
        Returns:
            Dictionary containing run results
        """
        try:
            run = self.client.agents.runs.create_and_process(
                thread_id=thread_id,
                agent_id=agent_id
            )
            print(f"✅ Agent run completed with status: {run.status}")
            return {
                "id": run.id,
                "thread_id": run.thread_id,
                "agent_id": run.agent_id,
                "status": run.status,
                "created_at": run.created_at,
                "completed_at": run.completed_at
            }
        except Exception as e:
            print(f"❌ Error running agent: {str(e)}")
            raise
    
    def get_messages(self, thread_id: str) -> list:
        """
        Retrieve messages from a thread
        
        Args:
            thread_id: Thread identifier
            
        Returns:
            List of messages
        """
        try:
            messages = self.client.agents.messages.list(thread_id=thread_id)
            # Convert ItemPaged to list
            message_list = list(messages)
            print(f"✅ Retrieved {len(message_list)} messages from thread")
            return [
                {
                    "id": msg.id,
                    "role": msg.role,
                    "content": msg.content,
                    "created_at": msg.created_at
                }
                for msg in message_list
            ]
        except Exception as e:
            print(f"❌ Error retrieving messages: {str(e)}")
            raise
    
    def delete_agent(self, agent_id: str) -> bool:
        """
        Delete an agent
        
        Args:
            agent_id: Agent identifier
            
        Returns:
            True if successful
        """
        try:
            self.client.agents.delete_agent(agent_id)
            print(f"✅ Agent {agent_id} deleted successfully")
            return True
        except Exception as e:
            print(f"❌ Error deleting agent: {str(e)}")
            return False


def main():
    """Main function to demonstrate agent creation and usage"""
    
    # Configuration from environment variables
    project_endpoint = os.getenv("PROJECT_ENDPOINT", "https://aifoundry6219.services.ai.azure.com/api/projects/project6219")
    model_deployment_name = os.getenv("MODEL_DEPLOYMENT_NAME", "gpt-4o-mini")
    
    if not project_endpoint or not model_deployment_name:
        print("❌ Missing required environment variables:")
        print("   PROJECT_ENDPOINT")
        print("   MODEL_DEPLOYMENT_NAME")
        return
    
    print(f"🚀 Creating AI agent with Azure AI Foundry...")
    print(f"   Project Endpoint: {project_endpoint}")
    print(f"   Model: {model_deployment_name}")
    
    try:
        # Initialize the agent creator
        creator = AIFoundryAgentCreator(project_endpoint, model_deployment_name)
        
        # Create an agent
        agent_info = creator.create_agent(
            name="SemanticKernelDemoAgent",
            instructions="You are a helpful AI assistant that can analyze data, write code, and answer questions. Be concise and practical in your responses.",
            tools=CodeInterpreterTool().definitions,
            description="Demo agent for Semantic Kernel integration"
        )
        
        # Create a conversation thread
        thread_info = creator.create_thread()
        
        # Send a test message
        message_info = creator.send_message(
            thread_id=thread_info["id"],
            content="Hello! Can you help me understand what capabilities you have?"
        )
        
        # Run the agent
        run_info = creator.run_agent(
            thread_id=thread_info["id"],
            agent_id=agent_info["id"]
        )
        
        # Get the response
        messages = creator.get_messages(thread_info["id"])
        
        print("\n📋 Conversation Summary:")
        for msg in reversed(messages):
            role_emoji = "👤" if msg["role"] == "user" else "🤖"
            print(f"{role_emoji} {msg['role'].upper()}: {msg['content']}")
        
        print(f"\n🎉 Success! Agent '{agent_info['name']}' is ready for Semantic Kernel integration")
        print(f"   Agent ID: {agent_info['id']}")
        print(f"   Thread ID: {thread_info['id']}")
        
        return {
            "agent": agent_info,
            "thread": thread_info,
            "success": True
        }
        
    except Exception as e:
        print(f"💥 Failed to create agent: {str(e)}")
        return {"success": False, "error": str(e)}


if __name__ == "__main__":
    main()