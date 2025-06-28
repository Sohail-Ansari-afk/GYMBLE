import requests
import json
import time
from datetime import datetime
import sys

# Base URL for the API
BASE_URL = "http://localhost:8000/api"

# Test user data with timestamp to ensure uniqueness
TEST_USER = {
    "email": f"test_user_{int(time.time())}@example.com",
    "password": "password123",
    "name": "Test User",
    "phone": "+1234567890",
    "role": "owner"
}

# Test member data (will be populated after getting gym and plan data)
TEST_MEMBER = {
    "email": f"test_member_{int(time.time())}@example.com",
    "password": "password123",
    "name": "Test Member",
    "phone": "+1987654321",
    "gym_id": "",  # Will be populated later
    "plan_id": ""   # Will be populated later
}

def print_header(title):
    """Print a header with a title for better readability"""
    print("\n" + "=" * 60)
    print(f" {title} ")
    print("=" * 60)

def print_separator(title):
    """Print a separator with a title for better readability"""
    print("\n" + "-" * 40)
    print(f" {title} ")
    print("-" * 40)

def test_signup():
    """Test user signup/registration"""
    print_separator("Testing User Signup")
    
    url = f"{BASE_URL}/auth/register"
    response = requests.post(url, json=TEST_USER)
    
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200 or response.status_code == 201:
        data = response.json()
        print("Signup successful!")
        print(f"Access Token: {data['access_token'][:20]}...")
        print(f"User ID: {data['user']['id']}")
        print(f"User Email: {data['user']['email']}")
        print(f"User Role: {data['user']['role']}")
        return data
    else:
        print(f"Signup failed: {response.text}")
        return None

def test_login(email, password):
    """Test user login"""
    print_separator("Testing User Login")
    
    url = f"{BASE_URL}/auth/login"
    response = requests.post(url, json={
        "email": email,
        "password": password
    })
    
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print("Login successful!")
        print(f"Access Token: {data['access_token'][:20]}...")
        print(f"User ID: {data['user']['id']}")
        print(f"User Email: {data['user']['email']}")
        print(f"User Role: {data['user']['role']}")
        return data
    else:
        print(f"Login failed: {response.text}")
        return None

def test_gym_availability():
    """Test gym availability"""
    print_separator("Testing Gym Availability")
    
    url = f"{BASE_URL}/gyms/all"
    
    # Test with regular request
    print("\nTesting with regular request:")
    try:
        response = requests.get(url)
        print(f"Status code: {response.status_code}")
        
        if response.status_code == 200:
            gyms = response.json()
            print(f"Successfully retrieved {len(gyms)} gyms")
            
            # Display first 3 gyms (or all if less than 3)
            for i, gym in enumerate(gyms[:3]):
                print(f"  Gym {i+1}: {gym.get('name', 'Unknown')} - {gym.get('address', 'No address')}")
            
            if len(gyms) > 3:
                print(f"  ... and {len(gyms)-3} more gyms")
                
            return gyms
        else:
            print(f"Failed to get gyms: {response.text}")
            return None
    except Exception as e:
        print(f"Error: {e}")
        return None

def test_flutter_web_connection():
    """Test the connection from Flutter web app to backend API"""
    print_separator("Testing Flutter Web Connection")
    
    url = f"{BASE_URL}/gyms/all"
    
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
            gyms = response.json()
            print(f"\nSuccessfully received {len(gyms)} gyms")
            return gyms
        else:
            print(f"\nFailed to get gyms: {response.text}")
            return None
    except Exception as e:
        print(f"Error: {e}")
        return None

def run_tests():
    """Run all tests in sequence"""
    print_header("GYMBLE Flutter App Test")
    print(f"Test timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Check if backend server is running
    print("\nChecking if backend server is running...")
    try:
        response = requests.get("http://localhost:8000")
        print("✓ Backend server is running!")
    except requests.exceptions.ConnectionError:
        print("✗ Backend server is not running. Please start the server and try again.")
        return
    
    # Test gym availability first to check API connectivity
    print("\nTesting API connectivity by checking gym availability...")
    gyms = test_gym_availability()
    if gyms is None:
        print("\nAPI connectivity test failed. Please check the backend server.")
        # Continue with other tests anyway
    
    # Test Flutter web connection
    print("\nTesting Flutter web connection...")
    web_gyms = test_flutter_web_connection()
    if web_gyms is None:
        print("\nFlutter web connection test failed. CORS issues may be present.")
        # Continue with other tests anyway
    
    # Test signup
    user_data = test_signup()
    if not user_data:
        print("\nUser signup failed. Stopping tests.")
        return
    
    # Test login
    login_data = test_login(TEST_USER["email"], TEST_USER["password"])
    if not login_data:
        print("\nUser login failed. Stopping tests.")
        return
    
    print_header("Test Summary")
    print("✓ Backend server is running")
    print(f"✓ Gym availability test: {'Passed' if gyms else 'Failed'}")
    print(f"✓ Flutter web connection test: {'Passed' if web_gyms else 'Failed'}")
    print("✓ User signup test: Passed")
    print("✓ User login test: Passed")
    
    print("\nAll tests completed!")

if __name__ == "__main__":
    run_tests()