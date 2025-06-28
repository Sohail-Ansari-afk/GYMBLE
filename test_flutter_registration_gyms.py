import requests
import json
import sys

# Base URL for the backend API
BASE_URL = "http://localhost:8000/api"

def print_separator(title):
    """Print a separator with title"""
    print("\n" + "=" * 60)
    print(f" {title}")
    print("=" * 60)

def test_gym_visibility():
    """Test if gyms are visible and match the expected count"""
    print_separator("Testing Gym Visibility in Registration Page")
    
    # Fetch gyms from the backend API
    url = f"{BASE_URL}/gyms/all"
    
    try:
        response = requests.get(url)
        print(f"Status code: {response.status_code}")
        
        if response.status_code == 200:
            gyms = response.json()
            print(f"Successfully retrieved {len(gyms)} gyms")
            
            # Print the first few gyms
            for i, gym in enumerate(gyms[:min(9, len(gyms))]):
                print(f"  Gym {i+1}: {gym['name']} - {gym.get('city', '')}")
            
            if len(gyms) > 9:
                print(f"  ... and {len(gyms) - 9} more gyms")
            
            # Verify if we have the expected 9 gyms
            if len(gyms) == 9:
                print("\n✓ Found exactly 9 gyms as expected")
            else:
                print(f"\n! Expected 9 gyms, but found {len(gyms)} gyms")
                
            return gyms
        else:
            print(f"Failed to retrieve gyms: {response.status_code}")
            print(f"Response: {response.text}")
            return None
    except Exception as e:
        print(f"Error: {e}")
        return None

def test_flutter_web_connection():
    """Test if Flutter web app can connect to the backend API"""
    print_separator("Testing Flutter Web Connection to Backend")
    
    url = f"{BASE_URL}/gyms/all"
    headers = {
        'Origin': 'http://localhost:52914',
        'X-Requested-With': 'XMLHttpRequest'
    }
    
    try:
        response = requests.get(url, headers=headers)
        print(f"Status code: {response.status_code}")
        
        # Check CORS headers
        cors_headers = {
            'Access-Control-Allow-Origin': response.headers.get('Access-Control-Allow-Origin'),
            'Access-Control-Allow-Methods': response.headers.get('Access-Control-Allow-Methods'),
            'Access-Control-Allow-Headers': response.headers.get('Access-Control-Allow-Headers')
        }
        
        print("\nCORS Headers:")
        for header, value in cors_headers.items():
            print(f"  {header}: {value}")
        
        if response.status_code == 200:
            gyms = response.json()
            print(f"\nSuccessfully retrieved {len(gyms)} gyms with CORS headers")
            return True
        else:
            print(f"Failed to retrieve gyms with CORS headers: {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    """Main function to run tests"""
    print("Starting tests to verify gym visibility in Flutter registration page...")
    
    # Test 1: Check if gyms are visible
    gyms = test_gym_visibility()
    
    # Test 2: Check if Flutter web app can connect to backend
    flutter_connection = test_flutter_web_connection()
    
    # Summary
    print_separator("Test Summary")
    if gyms is not None:
        print(f"✓ Gym visibility test: {len(gyms)} gyms available")
    else:
        print("✗ Gym visibility test: Failed to retrieve gyms")
    
    if flutter_connection:
        print("✓ Flutter web connection test: Passed")
    else:
        print("✗ Flutter web connection test: Failed")
    
    print("\nNote: If both tests pass, the 9 gyms should be visible in the Flutter registration page.")
    print("To verify visually, open the Flutter app in a browser and navigate to the registration page.")

if __name__ == "__main__":
    main()