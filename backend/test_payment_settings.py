import requests
import json
import base64
import os
from PIL import Image
import io
import sys

# Configuration
BASE_URL = "http://localhost:8000"
TEST_UPI_ID = "test@upi"
TEST_IMAGE_PATH = "test_qr.png"  # Will be created during test

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

# Create a test QR code image
def create_test_qr_image():
    try:
        # Create a simple black and white image for testing
        img = Image.new('RGB', (200, 200), color='white')
        pixels = img.load()
        
        # Draw a simple pattern (not a real QR code, just for testing)
        for i in range(40, 160):
            for j in range(40, 160):
                if (i + j) % 20 < 10:
                    pixels[i, j] = (0, 0, 0)
        
        img.save(TEST_IMAGE_PATH)
        print_success(f"Created test QR image at {TEST_IMAGE_PATH}")
        return True
    except Exception as e:
        print_error(f"Failed to create test QR image: {str(e)}")
        return False

# Convert image to base64
def image_to_base64(image_path):
    try:
        with open(image_path, "rb") as img_file:
            return base64.b64encode(img_file.read()).decode('utf-8')
    except Exception as e:
        print_error(f"Failed to convert image to base64: {str(e)}")
        return None

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

# Test GET payment settings endpoint
def test_get_payment_settings(token):
    print_header("Testing GET /api/gym/payment-settings")
    
    try:
        response = requests.get(
            f"{BASE_URL}/api/gym/payment-settings",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        print_info(f"Status code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print_success("Successfully retrieved payment settings")
            print_info(f"UPI ID: {data.get('upi_id')}")
            print_info(f"QR Code data present: {'Yes' if data.get('qr_code_data') else 'No'}")
            return True
        else:
            print_error(f"Failed to get payment settings: {response.text}")
            return False
    except Exception as e:
        print_error(f"Error during GET request: {str(e)}")
        return False

# Test PATCH payment settings endpoint
def test_update_payment_settings(token):
    print_header("Testing PATCH /api/gym/payment-settings")
    
    # Create test data
    qr_code_base64 = image_to_base64(TEST_IMAGE_PATH)
    if not qr_code_base64:
        return False
    
    payload = {
        "upi_id": TEST_UPI_ID,
        "qr_code": qr_code_base64
    }
    
    try:
        response = requests.patch(
            f"{BASE_URL}/api/gym/payment-settings",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            data=json.dumps(payload)
        )
        
        print_info(f"Status code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print_success("Successfully updated payment settings")
            print_info(f"Updated UPI ID: {data.get('upi_id')}")
            print_info(f"Updated QR Code data present: {'Yes' if data.get('qr_code_data') else 'No'}")
            
            # Verify the update by getting the settings again
            print_info("Verifying update by fetching settings again...")
            if test_get_payment_settings(token):
                return True
            else:
                print_error("Verification failed")
                return False
        else:
            print_error(f"Failed to update payment settings: {response.text}")
            return False
    except Exception as e:
        print_error(f"Error during PATCH request: {str(e)}")
        return False

# Main test function
def run_tests():
    print_header("PAYMENT SETTINGS API TEST")
    
    # Create test QR image
    if not create_test_qr_image():
        return
    
    # Get JWT token
    token = get_jwt_token()
    if not token:
        return
    
    # Run tests
    get_success = test_get_payment_settings(token)
    update_success = test_update_payment_settings(token)
    
    # Clean up
    try:
        if os.path.exists(TEST_IMAGE_PATH):
            os.remove(TEST_IMAGE_PATH)
            print_success(f"Removed test QR image {TEST_IMAGE_PATH}")
    except Exception as e:
        print_error(f"Failed to remove test image: {str(e)}")
    
    # Summary
    print_header("TEST SUMMARY")
    if get_success:
        print_success("GET /api/gym/payment-settings: PASSED")
    else:
        print_error("GET /api/gym/payment-settings: FAILED")
    
    if update_success:
        print_success("PATCH /api/gym/payment-settings: PASSED")
    else:
        print_error("PATCH /api/gym/payment-settings: FAILED")

if __name__ == "__main__":
    run_tests()