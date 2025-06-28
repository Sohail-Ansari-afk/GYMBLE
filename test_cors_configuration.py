import requests
import json
import sys

def test_cors_configuration():
    """Test the CORS configuration of the backend server"""
    base_url = "http://localhost:8000/api"
    test_endpoint = "/gyms/all"  # The endpoint that's failing in the Flutter app
    url = f"{base_url}{test_endpoint}"
    
    # List of origins to test
    origins = [
        "http://localhost:52914",  # Flutter web app port
        "http://127.0.0.1:52914",  # Alternative localhost
        "http://localhost:3000",   # React dev server (should be allowed)
        "http://localhost:8000",   # Same as backend
        "https://example.com",     # External domain (should be blocked)
    ]
    
    print("\n===== CORS Configuration Test =====\n")
    print("This script tests if the backend server's CORS configuration")
    print("allows requests from different origins.\n")
    
    print("Testing CORS preflight (OPTIONS) requests from different origins:\n")
    
    results = {}
    
    for origin in origins:
        print(f"Testing origin: {origin}")
        
        # Test OPTIONS request (preflight CORS check)
        try:
            headers = {
                'Origin': origin,
                'Access-Control-Request-Method': 'GET',
                'Access-Control-Request-Headers': 'Content-Type',
            }
            response = requests.options(url, headers=headers)
            
            # Check for CORS headers
            allow_origin = response.headers.get('Access-Control-Allow-Origin', None)
            allow_methods = response.headers.get('Access-Control-Allow-Methods', None)
            allow_headers = response.headers.get('Access-Control-Allow-Headers', None)
            allow_credentials = response.headers.get('Access-Control-Allow-Credentials', None)
            
            if allow_origin:
                if allow_origin == '*' or allow_origin == origin:
                    print(f"  ✓ Origin {origin} is allowed")
                    results[origin] = "Allowed"
                else:
                    print(f"  ✗ Origin {origin} is not explicitly allowed (got {allow_origin})")
                    results[origin] = f"Not allowed (got {allow_origin})"
            else:
                print(f"  ✗ No Access-Control-Allow-Origin header found")
                results[origin] = "No CORS headers"
                
            print(f"  Status code: {response.status_code}")
            if allow_methods:
                print(f"  Allowed methods: {allow_methods}")
            if allow_headers:
                print(f"  Allowed headers: {allow_headers}")
            if allow_credentials:
                print(f"  Credentials allowed: {allow_credentials}")
                
        except Exception as e:
            print(f"  Error: {e}")
            results[origin] = f"Error: {e}"
            
        print()
    
    # Summary
    print("\n===== CORS Test Summary =====\n")
    print("Origin                  | Result")
    print("-"*40)
    for origin, result in results.items():
        print(f"{origin.ljust(24)} | {result}")
    
    # Check if Flutter web origin is allowed
    flutter_web_origin = "http://localhost:52914"
    if results.get(flutter_web_origin) == "Allowed":
        print("\n✓ Flutter web origin is allowed by CORS configuration")
    else:
        print("\n✗ Flutter web origin is NOT allowed by CORS configuration")
        print("\nTo fix this issue:")
        print("1. Open server.py")
        print("2. Find the ALLOWED_ORIGINS list")
        print("3. Add the following entries if they're not already there:")
        print("   - \"http://localhost:52914\"")
        print("   - \"http://127.0.0.1:52914\"")
        print("4. Restart the backend server")

if __name__ == "__main__":
    test_cors_configuration()