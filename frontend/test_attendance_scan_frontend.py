import requests
import json
import time
import webbrowser
import os
import requests
from datetime import datetime

# Configuration
BACKEND_URL = "http://localhost:8000"  # Base URL without /api
API_URL = "http://localhost:8000/api"  # URL with /api prefix
FRONTEND_URL = "http://localhost:3000"    # Adjust if your frontend runs on a different port

# Test user credentials (using sample data from create_sample_data.py)
TEST_USER = {
    "email": "owner@gym.com",
    "password": "password123"
}

# Colors for terminal output
COLORS = {
    "GREEN": "\033[92m",
    "YELLOW": "\033[93m",
    "RED": "\033[91m",
    "BLUE": "\033[94m",
    "ENDC": "\033[0m",
    "BOLD": "\033[1m"
}

def print_header(text):
    print(f"\n{COLORS['BOLD']}{COLORS['BLUE']}=== {text} ==={COLORS['ENDC']}")

def print_success(text):
    print(f"{COLORS['GREEN']}✓ {text}{COLORS['ENDC']}")

def print_error(text):
    print(f"{COLORS['RED']}✗ {text}{COLORS['ENDC']}")

def print_info(text):
    print(f"{COLORS['YELLOW']}ℹ {text}{COLORS['ENDC']}")

def authenticate():
    print_header("Authenticating with backend")
    try:
        response = requests.post(f"{API_URL}/auth/login", json=TEST_USER)
        response.raise_for_status()
        token = response.json().get("access_token")
        print_success("Authentication successful")
        return token
    except requests.exceptions.RequestException as e:
        print_error(f"Authentication failed: {str(e)}")
        return None

def get_member_info(token):
    print_header("Retrieving member information")
    try:
        headers = {"Authorization": f"Bearer {token}"}
        # Since we're using an owner account, we'll get a list of members and use the first one
        response = requests.get(f"{API_URL}/members", headers=headers)
        response.raise_for_status()
        members = response.json()
        if not members:
            print_error("No members found in the gym")
            return None
        
        member_data = members[0]
        print_success(f"Retrieved member info for: {member_data.get('name')}")
        print("Member data structure:")
        for key in member_data.keys():
            print(f"  - {key}: {type(member_data[key]).__name__}")
        print("\nMember data:")
        print(json.dumps(member_data, indent=2))
        return member_data
    except requests.exceptions.RequestException as e:
        print_error(f"Failed to get member info: {str(e)}")
        return None

def get_qr_code(token):
    print_header("Retrieving QR code")
    try:
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(f"{API_URL}/attendance/qr-code", headers=headers)
        response.raise_for_status()
        qr_data = response.json()
        print_success("QR code retrieved successfully")
        return qr_data
    except requests.exceptions.RequestException as e:
        print_error(f"Failed to get QR code: {str(e)}")
        return None

def test_check_in(token, member_id, qr_code):
    print_header("Testing CHECK-IN operation")
    try:
        # First, get the member details directly from the database
        headers = {"Authorization": f"Bearer {token}"}
        
        # Proceed with check-in
        payload = {
            "member_id": member_id,
            "qr_code": qr_code,
            "timestamp": datetime.now().isoformat(),
            "action": "check-in"
        }
        print_info(f"Sending request: {json.dumps(payload, indent=2)}")
        
        response = requests.post(f"{API_URL}/attendance/scan", json=payload, headers=headers)
        if response.status_code == 500:
            error_text = response.text
            print_error(f"Response: {error_text}")
            return None
        
        response.raise_for_status()
        result = response.json()
        
        print_success(f"Check-in response: {json.dumps(result, indent=2)}")
        return result
    except requests.exceptions.RequestException as e:
        print_error(f"Check-in failed: {str(e)}")
        if hasattr(e, 'response') and e.response is not None:
            print_error(f"Response: {e.response.text}")
        return None

def test_check_out(token, member_id, qr_code):
    print_header("Testing CHECK-OUT operation")
    try:
        headers = {"Authorization": f"Bearer {token}"}
        payload = {
            "member_id": member_id,
            "qr_code": qr_code,
            "timestamp": datetime.now().isoformat(),
            "action": "check-out"
        }
        print_info(f"Sending request: {json.dumps(payload, indent=2)}")
        
        response = requests.post(f"{API_URL}/attendance/scan", json=payload, headers=headers)
        response.raise_for_status()
        result = response.json()
        
        print_success(f"Check-out response: {json.dumps(result, indent=2)}")
        return result
    except requests.exceptions.RequestException as e:
        print_error(f"Check-out failed: {str(e)}")
        if hasattr(e, 'response') and e.response is not None:
            print_error(f"Response: {e.response.text}")
        return None

def open_frontend():
    print_header("Opening frontend in browser")
    try:
        webbrowser.open(f"{FRONTEND_URL}/qr-scanner")
        print_success("Frontend opened in browser")
    except Exception as e:
        print_error(f"Failed to open frontend: {str(e)}")

def main():
    print_header("FRONTEND ATTENDANCE SCAN TEST")
    
    # Step 1: Authenticate
    token = authenticate()
    if not token:
        return
    
    # Step 2: Get member info
    member_data = get_member_info(token)
    if not member_data:
        return
    
    # Step 3: Get QR code
    qr_data = get_qr_code(token)
    if not qr_data:
        return
    
    # Step 4: Test check-in
    check_in_result = test_check_in(token, member_data["id"], qr_data["qr_code_data"])
    if not check_in_result:
        return
    
    # Step 5: Wait a few seconds to simulate time passing
    print_info("Waiting 5 seconds before check-out...")
    time.sleep(5)
    
    # Step 6: Test check-out
    check_out_result = test_check_out(token, member_data["id"], qr_data["qr_code_data"])
    if not check_out_result:
        return
    
    # Step 7: Open frontend for manual testing
    print_info("\nAll API tests completed successfully!")
    print_info("Would you like to open the frontend for manual testing? (y/n)")
    choice = input().lower()
    if choice == 'y':
        open_frontend()
    
    print_header("TEST COMPLETED")
    print_success("The attendance scan API has been successfully tested with the frontend!")
    print_info("You can now manually test the frontend by scanning QR codes or entering numeric codes.")

if __name__ == "__main__":
    main()