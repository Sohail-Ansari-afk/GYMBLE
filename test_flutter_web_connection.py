import requests
import json
import sys

def test_flutter_web_connection():
    """Test the connection from Flutter web app to backend API"""
    base_url = "http://localhost:8000/api"
    endpoints = [
        "/gyms/all",  # The endpoint that's failing in the Flutter app
    ]
    
    print("\n===== Flutter Web Connection Test =====\n")
    print("This script simulates how the Flutter web app connects to the backend API")
    
    for endpoint in endpoints:
        url = f"{base_url}{endpoint}"
        print(f"\nTesting endpoint: {url}")
        
        # Simulate XMLHttpRequest from Flutter web app
        try:
            print("\nSimulating XMLHttpRequest from Flutter web app:")
            headers = {
                'Origin': 'http://localhost:52914',  # Flutter web app origin
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Flutter/WebApp',
            }
            response = requests.get(url, headers=headers)
            print(f"Status code: {response.status_code}")
            print(f"Response headers: {json.dumps(dict(response.headers), indent=2)}")
            
            # Check for CORS headers
            print("\nCORS Headers Check:")
            cors_headers = [
                'Access-Control-Allow-Origin',
                'Access-Control-Allow-Methods',
                'Access-Control-Allow-Headers',
                'Access-Control-Allow-Credentials'
            ]
            
            for header in cors_headers:
                if header in response.headers:
                    print(f"✓ {header}: {response.headers[header]}")
                else:
                    print(f"✗ {header} not found in response headers")
            
            if response.status_code == 200:
                print(f"\nResponse body: {json.dumps(response.json(), indent=2)[:500]}..." 
                      if len(json.dumps(response.json())) > 500 else json.dumps(response.json(), indent=2))
            else:
                print(f"\nResponse body: {response.text}")
                
            # Check if the response is what we expect
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list):
                        print(f"\n✓ Successfully received list of {len(data)} gyms")
                        for i, gym in enumerate(data[:3]):  # Show first 3 gyms
                            print(f"  Gym {i+1}: {gym.get('name', 'Unknown')} - {gym.get('address', 'No address')}")
                        if len(data) > 3:
                            print(f"  ... and {len(data)-3} more gyms")
                    else:
                        print("\n✗ Expected a list of gyms but received a different data structure")
                except Exception as e:
                    print(f"\n✗ Error parsing response: {e}")
            else:
                print("\n✗ Failed to get successful response from API")
                
        except Exception as e:
            print(f"Error: {e}")
    
    print("\n" + "-"*50)
    print("\nDiagnosis and Recommendations:")
    print("1. If you see CORS headers missing, update server.py to include correct CORS configuration")
    print("2. If the server returns 404, check if the endpoint path is correct")
    print("3. If connection fails completely, ensure the backend server is running")
    print("4. Check that the Flutter web app is using the correct API URL in env_config.dart")
    print("5. Verify that the Flutter web app is making requests with the correct headers")

if __name__ == "__main__":
    test_flutter_web_connection()