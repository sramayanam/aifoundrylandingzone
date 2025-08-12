#!/usr/bin/env python3
"""
Azure Content Safety - Create Custom Blocklists for Political and Religious Content
=================================================================================

This script creates custom blocklists in Azure Content Safety for political and religious content filtering.
"""

import requests
import time
from typing import List, Dict

class BlocklistManager:
    """Manage Azure Content Safety blocklists"""
    
    def __init__(self, endpoint: str, api_key: str):
        self.endpoint = endpoint.rstrip('/')
        self.api_key = api_key
        self.headers = {
            'Ocp-Apim-Subscription-Key': api_key,
            'Content-Type': 'application/json'
        }
    
    def create_blocklist(self, blocklist_name: str, description: str) -> bool:
        """Create a new blocklist"""
        url = f"{self.endpoint}/contentsafety/text/blocklists/{blocklist_name}?api-version=2024-09-01"
        
        payload = {
            "description": description
        }
        
        try:
            response = requests.patch(url, headers=self.headers, json=payload)
            
            if response.status_code in [200, 201]:
                print(f"✅ Created blocklist: {blocklist_name}")
                return True
            elif response.status_code == 409:
                print(f"ℹ️  Blocklist already exists: {blocklist_name}")
                return True
            else:
                print(f"❌ Failed to create blocklist {blocklist_name}: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error creating blocklist {blocklist_name}: {str(e)}")
            return False
    
    def add_blocklist_items(self, blocklist_name: str, items: List[str]) -> bool:
        """Add items to a blocklist (batch operation)"""
        url = f"{self.endpoint}/contentsafety/text/blocklists/{blocklist_name}:addOrUpdateBlocklistItems?api-version=2024-09-01"
        
        # Convert items to the required format
        blocklist_items = [{"description": item, "text": item} for item in items]
        
        payload = {
            "blocklistItems": blocklist_items
        }
        
        try:
            response = requests.post(url, headers=self.headers, json=payload)
            
            if response.status_code == 200:
                result = response.json()
                added_count = len(result.get('blocklistItems', []))
                print(f"✅ Added {added_count} items to blocklist: {blocklist_name}")
                return True
            else:
                print(f"❌ Failed to add items to blocklist {blocklist_name}: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error adding items to blocklist {blocklist_name}: {str(e)}")
            return False
    
    def get_blocklist(self, blocklist_name: str) -> Dict:
        """Get blocklist information"""
        url = f"{self.endpoint}/contentsafety/text/blocklists/{blocklist_name}?api-version=2024-09-01"
        
        try:
            response = requests.get(url, headers=self.headers)
            
            if response.status_code == 200:
                return response.json()
            else:
                print(f"❌ Failed to get blocklist {blocklist_name}: {response.status_code} - {response.text}")
                return {}
                
        except Exception as e:
            print(f"❌ Error getting blocklist {blocklist_name}: {str(e)}")
            return {}
    
    def list_blocklists(self) -> List[Dict]:
        """List all blocklists"""
        url = f"{self.endpoint}/contentsafety/text/blocklists?api-version=2024-09-01"
        
        try:
            response = requests.get(url, headers=self.headers)
            
            if response.status_code == 200:
                result = response.json()
                return result.get('value', [])
            else:
                print(f"❌ Failed to list blocklists: {response.status_code} - {response.text}")
                return []
                
        except Exception as e:
            print(f"❌ Error listing blocklists: {str(e)}")
            return []


def get_political_terms() -> List[str]:
    """Get list of political terms for blocklist"""
    return [
        # High-impact political keywords
        "presidential election", "vote for", "political candidate", "campaign", "ballot",
        "democrat", "republican", "conservative", "liberal", "socialism", "capitalism",
        "political party", "government policy", "legislation", "congress", "senate",
        "impeachment", "presidential debate", "political rally", "voting rights",
        "immigration policy", "tax policy", "healthcare policy", "foreign policy",
        "political opinion", "partisan", "bipartisan", "political ideology",
        "election fraud", "voter suppression", "gerrymandering", "political corruption",
        "lobbying", "political donation", "campaign finance", "political endorsement",
        
        # Government and political institutions
        "white house", "capitol hill", "supreme court", "federal government",
        "state government", "local government", "political administration",
        "political appointment", "cabinet member", "political advisor",
        
        # Political movements and issues
        "political protest", "political demonstration", "civil rights movement",
        "political revolution", "political reform", "political activism",
        "political extremism", "political violence", "political terrorism",
        
        # International politics
        "diplomatic relations", "trade war", "international sanctions",
        "political alliance", "political treaty", "political summit",
        "political crisis", "regime change", "political asylum"
    ]


def get_religious_terms() -> List[str]:
    """Get list of religious terms for blocklist"""
    return [
        # Core religious concepts
        "religious belief", "faith tradition", "spiritual practice", "religious doctrine",
        "theological discussion", "religious interpretation", "religious teaching",
        "religious authority", "religious leader", "religious community",
        
        # Christianity
        "christian faith", "jesus christ", "christian doctrine", "biblical teaching",
        "christian salvation", "christian theology", "gospel message", "christian worship",
        "christian prayer", "christian denomination", "catholic church", "protestant church",
        
        # Islam
        "islamic faith", "muslim belief", "quran teaching", "islamic doctrine","namaz",
        "prophet muhammad", "islamic worship", "islamic prayer", "islamic theology",
        "sunni islam", "shia islam", "islamic jurisprudence", "islamic practice",
        
        # Judaism
        "jewish faith", "jewish belief", "torah teaching", "jewish doctrine",
        "jewish worship", "jewish prayer", "jewish theology", "jewish tradition",
        "orthodox judaism", "conservative judaism", "reform judaism",
        
        # Other major religions
        "hindu belief", "buddhist teaching", "sikh faith", "religious philosophy",
        "spiritual enlightenment", "religious meditation", "religious ritual",
        "religious ceremony", "religious holiday", "religious observance",
        
        # Religious institutions and practices
        "religious institution", "place of worship", "religious service",
        "religious education", "religious studies", "religious counseling",
        "religious guidance", "religious conversion", "religious mission",
        
        # Interfaith and religious dialogue
        "interfaith dialogue", "religious tolerance", "religious diversity",
        "religious freedom", "religious persecution", "religious discrimination",
        "religious conflict", "religious extremism", "religious fundamentalism",
        
        # Spiritual and mystical concepts
        "spiritual journey", "religious experience", "divine revelation",
        "religious miracle", "spiritual healing", "religious prophecy",
        "afterlife belief", "religious salvation", "spiritual awakening"
    ]


def main():
    """Main function to create blocklists"""
    
    print("\n" + "="*70)
    print("AZURE CONTENT SAFETY - BLOCKLIST CREATION")
    print("="*70)
    print("Creating custom blocklists for political and religious content")
    print("="*70)
    
    # Initialize the blocklist manager
    try:
        manager = BlocklistManager(
            endpoint="",
            api_key=""
        )
        print("✅ Blocklist manager initialized")
    except Exception as e:
        print(f"❌ Failed to initialize blocklist manager: {str(e)}")
        return
    
    # List existing blocklists
    print("\n📋 Existing blocklists:")
    existing_blocklists = manager.list_blocklists()
    if existing_blocklists:
        for blocklist in existing_blocklists:
            print(f"  - {blocklist.get('blocklistName', 'Unknown')} ({blocklist.get('description', 'No description')})")
    else:
        print("  No existing blocklists found")
    
    # Create political content blocklist
    print("\n🏛️  Creating political content blocklist...")
    political_success = manager.create_blocklist(
        blocklist_name="political-content-filter",
        description="Custom blocklist for political content as per company policy - blocks political discussions, election content, and partisan topics"
    )
    
    if political_success:
        print("📝 Adding political terms to blocklist...")
        political_terms = get_political_terms()
        print(f"Adding {len(political_terms)} political terms...")
        
        # Add terms in batches of 100 (API limit)
        batch_size = 100
        for i in range(0, len(political_terms), batch_size):
            batch = political_terms[i:i + batch_size]
            success = manager.add_blocklist_items("political-content-filter", batch)
            if success:
                print(f"  ✅ Added batch {i//batch_size + 1} ({len(batch)} terms)")
            else:
                print(f"  ❌ Failed to add batch {i//batch_size + 1}")
            time.sleep(1)  # Rate limiting
    
    # Create religious content blocklist
    print("\n⛪ Creating religious content blocklist...")
    religious_success = manager.create_blocklist(
        blocklist_name="religious-content-filter", 
        description="Custom blocklist for religious content as per company policy - blocks religious discussions, theological content, and faith-based topics"
    )
    
    if religious_success:
        print("📝 Adding religious terms to blocklist...")
        religious_terms = get_religious_terms()
        print(f"Adding {len(religious_terms)} religious terms...")
        
        # Add terms in batches of 100 (API limit)
        batch_size = 100
        for i in range(0, len(religious_terms), batch_size):
            batch = religious_terms[i:i + batch_size]
            success = manager.add_blocklist_items("religious-content-filter", batch)
            if success:
                print(f"  ✅ Added batch {i//batch_size + 1} ({len(batch)} terms)")
            else:
                print(f"  ❌ Failed to add batch {i//batch_size + 1}")
            time.sleep(1)  # Rate limiting
    
    # Verify created blocklists
    print("\n📋 Final blocklist status:")
    final_blocklists = manager.list_blocklists()
    for blocklist in final_blocklists:
        name = blocklist.get('blocklistName', 'Unknown')
        desc = blocklist.get('description', 'No description')
        print(f"  ✅ {name}")
        print(f"     Description: {desc}")
        
        # Get detailed info
        details = manager.get_blocklist(name)
        if details:
            print(f"     Created: {details.get('createdDate', 'Unknown')}")
            print(f"     Updated: {details.get('lastModifiedDate', 'Unknown')}")
    
    print("\n" + "="*70)
    print("🎉 BLOCKLIST CREATION COMPLETED")
    print("="*70)
    print("Next steps:")
    print("1. Test the blocklists using the test script")
    print("2. Configure your APIM policy to use these blocklists")
    print("3. Deploy and test the full integration")
    print("="*70)


if __name__ == "__main__":
    main()
