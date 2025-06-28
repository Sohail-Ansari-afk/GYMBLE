import requests
import json
import time
import webbrowser
import os
from datetime import datetime

# Configuration
API_URL = "http://localhost:8000"
FRONTEND_URL = "http://localhost:3000"
TEST_USER = {
    "email": "test@example.com",
    "password": "password123"
}

# ANSI colors for terminal output
COLOR_RED = "\033[91m"
COLOR_GREEN = "\033[92m"
COLOR_YELLOW = "\033[93m"
COLOR_BLUE = "\033[94m"
COLOR_RESET = "\033[0m"

def print_header(message):
    print(f"\n{COLOR_BLUE}==== {message} ===={COLOR_RESET}")

def print_success(message):
    print(f"{COLOR_GREEN}✓ {message}{COLOR_RESET}")

def print_error(message):
    print(f"{COLOR_RED}✗ {message}{COLOR_RESET}")

def print_warning(message):
    print(f"{COLOR_YELLOW}! {message}{COLOR_RESET}")

def print_json(data):
    print(json.dumps(data, indent=2))

def authenticate():
    print_header("Authenticating with backend")
    try:
        response = requests.post(f"{API_URL}/auth/login", json=TEST_USER)
        response.raise_for_status()
        token = response.json().get("access_token")
        user_id = response.json().get("user", {}).get("id")
        print_success("Authentication successful")
        return token, user_id
    except requests.exceptions.RequestException as e:
        print_error(f"Authentication failed: {str(e)}")
        return None, None

def get_qr_code(token):
    print_header("Getting QR code for attendance")
    try:
        response = requests.get(
            f"{API_URL}/api/attendance/qr-code",
            headers={"Authorization": f"Bearer {token}"}
        )
        response.raise_for_status()
        qr_data = response.json().get("qr_code_data")
        print_success("QR code retrieved successfully")
        return qr_data
    except requests.exceptions.RequestException as e:
        print_error(f"Failed to get QR code: {str(e)}")
        return None

def get_last_attendance_action(token, member_id):
    print_header("Getting last attendance action")
    try:
        response = requests.get(
            f"{API_URL}/api/attendance/last?memberId={member_id}",
            headers={"Authorization": f"Bearer {token}"}
        )
        response.raise_for_status()
        data = response.json()
        print_success("Last attendance action retrieved successfully")
        print_json(data)
        return data
    except requests.exceptions.RequestException as e:
        print_error(f"Failed to get last attendance action: {str(e)}")
        return None

def mark_attendance(token, member_id, qr_code, action):
    print_header(f"Marking attendance: {action}")
    try:
        payload = {
            "qr_code": qr_code,
            "member_id": member_id,
            "timestamp": datetime.now().isoformat(),
            "action": action,
            "coordinates": {"latitude": 0.0, "longitude": 0.0}
        }
        
        response = requests.post(
            f"{API_URL}/api/attendance",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            json=payload
        )
        
        response.raise_for_status()
        data = response.json()
        print_success(f"Attendance {action} successful")
        print_json(data)
        return data
    except requests.exceptions.RequestException as e:
        print_error(f"Failed to mark attendance: {str(e)}")
        return None

def open_flutter_web_app():
    print_header("Opening Flutter web app in browser")
    try:
        # For testing purposes, we'll use a simple URL that points to the Flutter web app
        # In a real scenario, you would need to have the Flutter app running on a web server
        webbrowser.open("http://localhost:8080")
        print_success("Flutter web app opened in browser")
        print_warning("Please ensure the Flutter web app is running on port 8080")
    except Exception as e:
        print_error(f"Failed to open Flutter web app: {str(e)}")

def main():
    print_header("ATTENDANCE FEATURE TEST")
    
    # Step 1: Authenticate
    token, user_id = authenticate()
    if not token or not user_id:
        return
    
    # Step 2: Get QR code
    qr_code = get_qr_code(token)
    if not qr_code:
        return
    
    # Step 3: Get last attendance action
    last_action = get_last_attendance_action(token, user_id)
    if not last_action:
        return
    
    # Step 4: Mark attendance (check-in or check-out based on last action)
    action = "check-in" if last_action.get("lastAction") == "check-out" else "check-out"
    result = mark_attendance(token, user_id, qr_code, action)
    if not result:
        return
    
    # Step 5: Get updated last attendance action
    updated_action = get_last_attendance_action(token, user_id)
    if not updated_action:
        return
    
    # Step 6: Open Flutter web app for visual testing
    open_flutter_web_app()
    
    print_header("TEST COMPLETED")
    print_success("All API tests passed successfully")
    print_warning("Please check the Flutter web app for visual confirmation")

if __name__ == "__main__":
    main()