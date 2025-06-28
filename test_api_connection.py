import requests
import json
import sys

def test_api_connection():
    """Test the connection to the backend API"""
    base_url = "http://localhost:8000/api"
    endpoints = [
        "/gyms/all",  # The endpoint that's failing in the Flutter app
        "/",         # Root API endpoint for basic connectivity test
    ]
    
    print("\n===== API Connection Test =====\n")
    
    for endpoint in endpoints:
        url = f"{base_url}{endpoint}"
        print(f"Testing endpoint: {url}")
        
        # Test regular GET request
        try:
            print("\n1. Testing regular GET request:")
            response = requests.get(url)
            print(f"Status code: {response.status_code}")
            print(f"Headers: {json.dumps(dict(response.headers), indent=2)}")
            if response.status_code == 200:
                print(f"Response body: {json.dumps(response.json(), indent=2)[:500]}..." 
                      if len(json.dumps(response.json())) > 500 else json.dumps(response.json(), indent=2))
            else:
                print(f"Response body: {response.text}")
        except Exception as e:
            print(f"Error: {e}")
        
        # Test OPTIONS request (preflight CORS check)
        try:
            print("\n2. Testing OPTIONS request (CORS preflight):")
            headers = {
                'Origin': 'http://localhost:52914',  # Simulate Flutter web app origin
                'Access-Control-Request-Method': 'GET',
                'Access-Control-Request-Headers': 'Content-Type',
            }
            response = requests.options(url, headers=headers)
            print(f"Status code: {response.status_code}")
            print(f"Headers: {json.dumps(dict(response.headers), indent=2)}")
            print(f"Response body: {response.text}")
            
            # Check for CORS headers
            cors_headers = [
                'Access-Control-Allow-Origin',
                'Access-Control-Allow-Methods',
                'Access-Control-Allow-Headers',
                'Access-Control-Allow-Credentials'
            ]
            
            print("\nCORS Headers Check:")
            for header in cors_headers:
                if header in response.headers:
                    print(f"✓ {header}: {response.headers[header]}")
                else:
                    print(f"✗ {header} not found in response headers")
                    
        except Exception as e:
            print(f"Error: {e}")
        
        # Test GET request with Origin header (simulating browser request)
        try:
            print("\n3. Testing GET with Origin header:")
            headers = {
                'Origin': 'http://localhost:52914',  # Simulate Flutter web app origin
                'Content-Type': 'application/json',
            }
            response = requests.get(url, headers=headers)
            print(f"Status code: {response.status_code}")
            print(f"Headers: {json.dumps(dict(response.headers), indent=2)}")
            if response.status_code == 200:
                print(f"Response body: {json.dumps(response.json(), indent=2)[:500]}..." 
                      if len(json.dumps(response.json())) > 500 else json.dumps(response.json(), indent=2))
            else:
                print(f"Response body: {response.text}")
        except Exception as e:
            print(f"Error: {e}")
            
        print("\n" + "-"*50 + "\n")

    print("\nRecommendations:")
    print("1. Check if the backend server is running on the correct port (8000)")
    print("2. Verify CORS configuration in server.py allows requests from http://localhost:52914")
    print("3. Ensure the API endpoint paths are correct")
    print("4. Check for any network issues or firewall restrictions")

if __name__ == "__main__":
    test_api_connection()