import requests
import json
import time
from datetime import datetime, timedelta

# Base URL for the API
BASE_URL = "http://localhost:8000/api"

# Test user credentials
TEST_USER = {
    "email": "lamil@gmail.com",
    "password": "password"
}

# Colors for console output
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.HEADER}{Colors.BOLD}=== {text} ==={Colors.ENDC}\n")

def print_success(text):
    print(f"{Colors.OKGREEN}✓ {text}{Colors.ENDC}")

def print_error(text):
    print(f"{Colors.FAIL}✗ {text}{Colors.ENDC}")

def print_info(text):
    print(f"{Colors.OKBLUE}ℹ {text}{Colors.ENDC}")

def print_warning(text):
    print(f"{Colors.WARNING}⚠ {text}{Colors.ENDC}")

# Test authentication
def test_authentication():
    print_header("Testing Authentication")
    
    # Test login
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            json=TEST_USER
        )
        
        if response.status_code == 200:
            data = response.json()
            token = data.get("access_token")
            user = data.get("user")
            
            if token and user:
                print_success(f"Login successful for {user.get('email')}")
                print_info(f"Token: {token[:10]}...")
                return token
            else:
                print_error("Login response missing token or user data")
                return None
        else:
            print_error(f"Login failed with status code {response.status_code}")
            print_info(f"Response: {response.text}")
            return None
    except Exception as e:
        print_error(f"Login request failed: {str(e)}")
        return None

# Test token validation
def test_token_validation(token):
    print_header("Testing Token Validation")
    
    if not token:
        print_warning("Skipping token validation (no token available)")
        return False
    
    try:
        # Use the /auth/me endpoint to validate the token
        response = requests.get(
            f"{BASE_URL}/auth/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 200:
            user_data = response.json()
            print_success(f"Token is valid - User: {user_data.get('email')}")
            return True
        else:
            print_error(f"Token validation failed with status code {response.status_code}")
            print_info(f"Response: {response.text}")
            return False
    except Exception as e:
        print_error(f"Token validation request failed: {str(e)}")
        return False

# Test database operations with retry mechanism
def test_database_operations(token):
    print_header("Testing Database Operations with Retry Mechanism")
    
    if not token:
        print_warning("Skipping database operations (no token available)")
        return
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test getting all gyms
    def test_get_gyms():
        max_retries = 3
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                print_info(f"Fetching gyms (Attempt {retry_count + 1}/{max_retries})")
                response = requests.get(f"{BASE_URL}/gyms/all", headers=headers)
                
                if response.status_code == 200:
                    gyms = response.json()
                    print_success(f"Successfully retrieved {len(gyms)} gyms")
                    return gyms
                else:
                    print_error(f"Failed to get gyms: {response.status_code} - {response.text}")
            except Exception as e:
                print_error(f"Request error: {str(e)}")
            
            retry_count += 1
            if retry_count < max_retries:
                wait_time = 2 ** retry_count  # Exponential backoff
                print_warning(f"Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
        
        print_error("All retry attempts failed")
        return None
    
    # Get all gyms
    gyms = test_get_gyms()
    
    if not gyms or len(gyms) == 0:
        print_warning("No gyms found, skipping member and plan tests")
        return
    
    # Use the first gym for further tests
    gym_id = gyms[0].get("id")
    print_info(f"Using gym with ID: {gym_id}")
    
    # Test getting members for a gym
    def test_get_members(gym_id):
        max_retries = 3
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                print_info(f"Fetching members for gym {gym_id} (Attempt {retry_count + 1}/{max_retries})")
                response = requests.get(f"{BASE_URL}/gym-members", headers=headers)
                
                if response.status_code == 200:
                    members = response.json()
                    print_success(f"Successfully retrieved {len(members)} members")
                    return members
                else:
                    print_error(f"Failed to get members: {response.status_code} - {response.text}")
            except Exception as e:
                print_error(f"Request error: {str(e)}")
            
            retry_count += 1
            if retry_count < max_retries:
                wait_time = 2 ** retry_count  # Exponential backoff
                print_warning(f"Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
        
        print_error("All retry attempts failed")
        return None
    
    # Get members for the gym
    members = test_get_members(gym_id)
    
    # Test getting plans for a gym
    def test_get_plans(gym_id):
        max_retries = 3
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                print_info(f"Fetching plans for gym {gym_id} (Attempt {retry_count + 1}/{max_retries})")
                response = requests.get(f"{BASE_URL}/plans/gym/{gym_id}", headers=headers)
                
                if response.status_code == 200:
                    plans = response.json()
                    print_success(f"Successfully retrieved {len(plans)} plans")
                    return plans
                else:
                    print_error(f"Failed to get plans: {response.status_code} - {response.text}")
            except Exception as e:
                print_error(f"Request error: {str(e)}")
            
            retry_count += 1
            if retry_count < max_retries:
                wait_time = 2 ** retry_count  # Exponential backoff
                print_warning(f"Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
        
        print_error("All retry attempts failed")
        return None
    
    # Get plans for the gym
    plans = test_get_plans(gym_id)

# Main test function
def run_tests():
    print_header("Starting API and Database Tests")
    
    # Test authentication
    token = test_authentication()
    
    # Test token validation
    is_valid = test_token_validation(token)
    
    # Test database operations with retry mechanism
    if is_valid:
        test_database_operations(token)
    
    print_header("Tests Completed")

# Run the tests
if __name__ == "__main__":
    run_tests()