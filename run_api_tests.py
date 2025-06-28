import subprocess
import os
import sys

def run_tests():
    """Run both API connection tests and provide a summary"""
    print("\n===== GYMBLE API Connection Test Suite =====\n")
    print("This script will run tests to diagnose the connection issues between")
    print("the Flutter web app and the backend API server.\n")
    
    # Check if backend server is running
    print("Checking if backend server is running...")
    try:
        import requests
        response = requests.get("http://localhost:8000")
        print(f"✓ Backend server is running (Status: {response.status_code})\n")
    except Exception as e:
        print(f"✗ Backend server may not be running: {e}\n")
        print("Please start the backend server with:")
        print("cd backend && python -m uvicorn server:app --reload")
        print("\nThen run this script again.")
        return
    
    # Run the API connection test
    print("\n1. Running general API connection test...\n")
    try:
        subprocess.run([sys.executable, "test_api_connection.py"], check=True)
    except subprocess.CalledProcessError:
        print("Error running API connection test")
    except Exception as e:
        print(f"Error: {e}")
    
    # Run the Flutter web connection test
    print("\n2. Running Flutter web connection test...\n")
    try:
        subprocess.run([sys.executable, "test_flutter_web_connection.py"], check=True)
    except subprocess.CalledProcessError:
        print("Error running Flutter web connection test")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n===== Summary and Next Steps =====\n")
    print("Based on the test results above, here are possible solutions:")
    print("\n1. CORS Configuration Issues:")
    print("   - Ensure ALLOWED_ORIGINS in server.py includes 'http://localhost:52914'")
    print("   - Check that CORSMiddleware is properly configured in server.py")
    print("\n2. API Endpoint Issues:")
    print("   - Verify the /api/gyms/all endpoint exists and returns data")
    print("   - Check for any authentication requirements")
    print("\n3. Flutter Web Configuration:")
    print("   - Ensure WEB_API_BASE_URL in .env is set to 'http://localhost:8000/api'")
    print("   - Check that the Flutter app is correctly loading environment variables")
    print("\n4. Network/Firewall Issues:")
    print("   - Check for any firewall or network restrictions")
    print("   - Try using 127.0.0.1 instead of localhost")
    
    print("\nFor more detailed debugging:")
    print("1. Add print statements in the Flutter app's api_service.dart")
    print("2. Check the browser console for CORS errors when running the Flutter web app")
    print("3. Add more detailed logging in the backend server.py file")

if __name__ == "__main__":
    run_tests()