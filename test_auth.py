import requests
import json
import time
from datetime import datetime

# Base URL for the API
BASE_URL = "http://localhost:8000/api"

# Test user data
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

def print_separator(title):
    """Print a separator with a title for better readability"""
    print("\n" + "=" * 50)
    print(f" {title} ")
    print("=" * 50)

def test_register_user():
    """Test user registration"""
    print_separator("Testing User Registration")
    
    url = f"{BASE_URL}/auth/register"
    response = requests.post(url, json=TEST_USER)
    
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200 or response.status_code == 201:
        data = response.json()
        print("Registration successful!")
        print(f"Access Token: {data['access_token'][:20]}...")
        print(f"User ID: {data['user']['id']}")
        print(f"User Email: {data['user']['email']}")
        print(f"User Role: {data['user']['role']}")
        return data
    else:
        print(f"Registration failed: {response.text}")
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

def test_validate_token(token):
    """Test token validation"""
    print_separator("Testing Token Validation")
    
    url = f"{BASE_URL}/auth/me"
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(url, headers=headers)
    
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print("Token is valid!")
        print(f"User ID: {data['id']}")
        print(f"User Email: {data['email']}")
        print(f"User Role: {data['role']}")
        return True
    else:
        print(f"Token validation failed: {response.text}")
        return False

def test_create_gym(token):
    """Test creating a gym"""
    print_separator("Testing Gym Creation")
    
    url = f"{BASE_URL}/gyms"
    headers = {"Authorization": f"Bearer {token}"}
    gym_data = {
        "name": f"Test Gym {int(time.time())}",
        "address": "123 Test Street, Test City",
        "phone": "+1234567890",
        "email": f"test_gym_{int(time.time())}@example.com",
        "description": "A test gym for API testing"
    }
    
    response = requests.post(url, json=gym_data, headers=headers)
    
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200 or response.status_code == 201:
        data = response.json()
        print("Gym creation successful!")
        print(f"Gym ID: {data['id']}")
        print(f"Gym Name: {data['name']}")
        return data
    else:
        print(f"Gym creation failed: {response.text}")
        return None

def test_create_plan(token, gym_id):
    """Test creating a membership plan"""
    print_separator("Testing Plan Creation")
    
    url = f"{BASE_URL}/plans"
    headers = {"Authorization": f"Bearer {token}"}
    plan_data = {
        "name": f"Test Plan {int(time.time())}",
        "description": "A test plan for API testing",
        "price": 999.99,
        "duration_days": 30,
        "plan_type": "basic",
        "features": ["Access to gym", "Basic equipment"],
        "auto_renewal": True
    }
    
    response = requests.post(url, json=plan_data, headers=headers)
    
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200 or response.status_code == 201:
        data = response.json()
        print("Plan creation successful!")
        print(f"Plan ID: {data['id']}")
        print(f"Plan Name: {data['name']}")
        print(f"Plan Price: {data['price']}")
        return data
    else:
        print(f"Plan creation failed: {response.text}")
        return None

def test_register_member(gym_id, plan_id):
    """Test member registration"""
    print_separator("Testing Member Registration")
    
    # Update the test member data with gym and plan IDs
    TEST_MEMBER["gym_id"] = gym_id
    TEST_MEMBER["plan_id"] = plan_id
    
    url = f"{BASE_URL}/auth/register-member"
    response = requests.post(url, json=TEST_MEMBER)
    
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200 or response.status_code == 201:
        data = response.json()
        print("Member registration successful!")
        print(f"Access Token: {data['access_token'][:20]}...")
        print(f"User ID: {data['user']['id']}")
        print(f"User Email: {data['user']['email']}")
        print(f"User Role: {data['user']['role']}")
        return data
    else:
        print(f"Member registration failed: {response.text}")
        return None

def run_tests():
    """Run all tests in sequence"""
    # Test user registration
    user_data = test_register_user()
    if not user_data:
        print("\nUser registration failed. Stopping tests.")
        return
    
    # Test user login
    login_data = test_login(TEST_USER["email"], TEST_USER["password"])
    if not login_data:
        print("\nUser login failed. Stopping tests.")
        return
    
    # Test token validation
    token = login_data["access_token"]
    if not test_validate_token(token):
        print("\nToken validation failed. Stopping tests.")
        return
    
    # Test gym creation
    gym_data = test_create_gym(token)
    if not gym_data:
        print("\nGym creation failed. Stopping tests.")
        return
    
    # Test plan creation
    plan_data = test_create_plan(token, gym_data["id"])
    if not plan_data:
        print("\nPlan creation failed. Stopping tests.")
        return
    
    # Test member registration
    member_data = test_register_member(gym_data["id"], plan_data["id"])
    if not member_data:
        print("\nMember registration failed. Stopping tests.")
        return
    
    # Test member login
    member_login = test_login(TEST_MEMBER["email"], TEST_MEMBER["password"])
    if not member_login:
        print("\nMember login failed. Stopping tests.")
        return
    
    # Test member token validation
    member_token = member_login["access_token"]
    test_validate_token(member_token)
    
    print("\n\nAll tests completed successfully!")

if __name__ == "__main__":
    print("Starting GYMBLE Authentication API Tests...")
    print(f"Test timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    run_tests()