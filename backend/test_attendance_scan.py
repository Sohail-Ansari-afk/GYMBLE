import requests
import json
import datetime
import time
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000"

# Colors for terminal output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    ENDC = '\033[0m'

def print_header(text):
    print(f"\n{Colors.BLUE}{'=' * 50}{Colors.ENDC}")
    print(f"{Colors.BLUE}{text.center(50)}{Colors.ENDC}")
    print(f"{Colors.BLUE}{'=' * 50}{Colors.ENDC}\n")

def print_success(text):
    print(f"{Colors.GREEN}✓ {text}{Colors.ENDC}")

def print_error(text):
    print(f"{Colors.RED}✗ {text}{Colors.ENDC}")

def print_info(text):
    print(f"{Colors.YELLOW}ℹ {text}{Colors.ENDC}")

# Get JWT token
def get_jwt_token():
    # Using default owner credentials from create_sample_data.py
    email = "owner@gym.com"
    password = "password123"
    
    print_info(f"Logging in automatically with default owner account: {email}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/auth/login", 
            json={"email": email, "password": password}
        )
        
        if response.status_code == 200:
            token = response.json().get("access_token")
            print_success("Successfully obtained JWT token")
            return token
        else:
            print_error(f"Failed to get token: {response.text}")
            print_info("Falling back to manual input...")
            
            print_info("Enter email:")
            email = input().strip()
            print_info("Enter password:")
            password = input().strip()
            
            response = requests.post(
                f"{BASE_URL}/api/auth/login", 
                json={"email": email, "password": password}
            )
            
            if response.status_code == 200:
                token = response.json().get("access_token")
                print_success("Successfully obtained JWT token")
                return token
            else:
                print_error(f"Failed to get token: {response.text}")
                return None
    except Exception as e:
        print_error(f"Error during authentication: {str(e)}")
        return None

# Get member ID
def get_member_id(token):
    try:
        response = requests.get(
            f"{BASE_URL}/api/members",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 200:
            members = response.json()
            if members and len(members) > 0:
                member_id = members[0]["id"]
                member_name = members[0]["name"]
                print_success(f"Using member: {member_name} (ID: {member_id})")
                return member_id
            else:
                print_error("No members found")
                return None
        else:
            print_error(f"Failed to get members: {response.text}")
            return None
    except Exception as e:
        print_error(f"Error getting members: {str(e)}")
        return None

# Get QR code data
def get_qr_code(token):
    try:
        response = requests.get(
            f"{BASE_URL}/api/attendance/qr-code",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 200:
            qr_data = response.json().get("qr_code_data")
            print_success(f"Got QR code data: {qr_data}")
            return qr_data
        else:
            print_error(f"Failed to get QR code: {response.text}")
            return None
    except Exception as e:
        print_error(f"Error getting QR code: {str(e)}")
        return None

# Test check-in
def test_check_in(token, member_id, qr_code):
    print_header("Testing Check-In")
    
    payload = {
        "member_id": member_id,
        "qr_code": qr_code,
        "timestamp": datetime.utcnow().isoformat(),
        "action": "check-in"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/attendance/scan",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            data=json.dumps(payload)
        )
        
        print_info(f"Status code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"Check-in response: {json.dumps(data, indent=2)}")
            return data
        else:
            print_error(f"Failed to check in: {response.text}")
            return None
    except Exception as e:
        print_error(f"Error during check-in: {str(e)}")
        return None

# Test check-out
def test_check_out(token, member_id, qr_code):
    print_header("Testing Check-Out")
    
    payload = {
        "member_id": member_id,
        "qr_code": qr_code,
        "timestamp": datetime.utcnow().isoformat(),
        "action": "check-out"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/attendance/scan",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            data=json.dumps(payload)
        )
        
        print_info(f"Status code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"Check-out response: {json.dumps(data, indent=2)}")
            return data
        else:
            print_error(f"Failed to check out: {response.text}")
            return None
    except Exception as e:
        print_error(f"Error during check-out: {str(e)}")
        return None

# Main test function
def run_tests():
    print_header("ATTENDANCE SCAN API TEST")
    
    # Get JWT token
    token = get_jwt_token()
    if not token:
        return
    
    # Get member ID
    member_id = get_member_id(token)
    if not member_id:
        return
    
    # Get QR code
    qr_code = get_qr_code(token)
    if not qr_code:
        return
    
    # Run tests
    check_in_result = test_check_in(token, member_id, qr_code)
    
    if check_in_result and check_in_result.get("success"):
        # Wait a bit to simulate time passing
        print_info("Waiting 5 seconds before check-out...")
        time.sleep(5)
        
        # Get a fresh QR code for check-out
        qr_code = get_qr_code(token)
        if not qr_code:
            return
        
        check_out_result = test_check_out(token, member_id, qr_code)
    
    # Summary
    print_header("TEST SUMMARY")
    if check_in_result:
        if check_in_result.get("success"):
            print_success("Check-in test: PASSED")
        else:
            print_error(f"Check-in test: FAILED - {check_in_result.get('message')}")
    else:
        print_error("Check-in test: FAILED")
    
    if 'check_out_result' in locals():
        if check_out_result and check_out_result.get("success"):
            print_success("Check-out test: PASSED")
        else:
            print_error(f"Check-out test: FAILED - {check_out_result.get('message') if check_out_result else 'No response'}")

if __name__ == "__main__":
    run_tests()