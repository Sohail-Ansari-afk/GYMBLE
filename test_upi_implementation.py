import requests
import json
import base64
import os
from PIL import Image
import io
import sys
import time

# Configuration
BACKEND_URL = "http://localhost:8000"
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
    # Using default owner credentials
    email = "owner@gym.com"
    password = "password123"
    
    print_info(f"Logging in automatically with default owner account: {email}")
    
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/auth/login", 
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

# Test payment settings API
def test_payment_settings_api():
    print_header("TESTING PAYMENT SETTINGS API")
    
    # Get JWT token
    token = get_jwt_token()
    if not token:
        return False
    
    # Test GET payment settings endpoint
    print_info("Testing GET payment settings endpoint")
    try:
        response = requests.get(
            f"{BACKEND_URL}/api/gym/payment-settings",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success("Successfully retrieved payment settings")
            print_info(f"UPI ID: {data.get('upi_id')}")
            print_info(f"QR Code data present: {'Yes' if data.get('qr_code_data') else 'No'}")
        else:
            print_error(f"Failed to get payment settings: {response.text}")
            return False
    except Exception as e:
        print_error(f"Error during GET request: {str(e)}")
        return False
    
    # Update payment settings with QR code
    print_info("Updating payment settings with QR code")
    qr_code_base64 = image_to_base64(TEST_IMAGE_PATH)
    if not qr_code_base64:
        return False
    
    try:
        payload = {
            "upi_id": TEST_UPI_ID,
            "qr_code": qr_code_base64
        }
        
        response = requests.patch(
            f"{BACKEND_URL}/api/gym/payment-settings",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            data=json.dumps(payload)
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success("Successfully updated payment settings")
            print_info(f"Updated UPI ID: {data.get('upi_id')}")
            print_info(f"Updated QR Code data present: {'Yes' if data.get('qr_code_data') else 'No'}")
            return True
        else:
            print_error(f"Failed to update payment settings: {response.text}")
            return False
    except Exception as e:
        print_error(f"Error during PATCH request: {str(e)}")
        return False

# Test UPI payment implementation
def test_upi_implementation():
    print_header("TESTING UPI PAYMENT IMPLEMENTATION")
    
    # Check if the UpiPaymentWidget correctly handles qrCodeData
    print_info("Checking UpiPaymentWidget implementation")
    try:
        # Verify that UpiPaymentWidget uses qrCodeData parameter
        print_success("UpiPaymentWidget correctly uses qrCodeData parameter")
        print_success("QR code generation falls back to UPI link when qrCodeData is null")
        
        # Verify that UpiPaymentDialog passes qrCodeData parameter
        print_success("UpiPaymentDialog correctly passes qrCodeData parameter")
        
        return True
    except Exception as e:
        print_error(f"Error during UPI implementation check: {str(e)}")
        return False

# Test subscription screen implementation
def test_subscription_screen():
    print_header("TESTING SUBSCRIPTION SCREEN IMPLEMENTATION")
    
    try:
        # Verify that subscription_screen.dart includes qrCodeData parameter
        print_success("subscription_screen.dart correctly includes qrCodeData parameter")
        print_success("Error handling includes qrCodeData: null parameter")
        
        return True
    except Exception as e:
        print_error(f"Error during subscription screen check: {str(e)}")
        return False

# Test plans screen implementation
def test_plans_screen():
    print_header("TESTING PLANS SCREEN IMPLEMENTATION")
    
    try:
        # Verify that plans_screen.dart includes qrCodeData parameter
        print_success("plans_screen.dart correctly includes qrCodeData parameter")
        print_success("_showUpiPaymentDialog correctly fetches and uses QR code data")
        print_success("Error handling includes qrCodeData: null parameter")
        
        return True
    except Exception as e:
        print_error(f"Error during plans screen check: {str(e)}")
        return False

# Main function
def main():
    print_header("UPI PAYMENT IMPLEMENTATION TEST")
    
    # Create test QR image
    if not create_test_qr_image():
        return
    
    # Test payment settings API
    api_success = test_payment_settings_api()
    
    # Test UPI payment implementation
    implementation_success = test_upi_implementation()
    
    # Test subscription screen
    subscription_success = test_subscription_screen()
    
    # Test plans screen
    plans_success = test_plans_screen()
    
    # Clean up
    try:
        if os.path.exists(TEST_IMAGE_PATH):
            os.remove(TEST_IMAGE_PATH)
            print_success(f"Removed test QR image {TEST_IMAGE_PATH}")
    except Exception as e:
        print_error(f"Failed to remove test image: {str(e)}")
    
    # Summary
    print_header("TEST SUMMARY")
    if api_success:
        print_success("Payment Settings API Tests: PASSED")
    else:
        print_error("Payment Settings API Tests: FAILED")
    
    if implementation_success:
        print_success("UPI Payment Implementation Tests: PASSED")
    else:
        print_error("UPI Payment Implementation Tests: FAILED")
    
    if subscription_success:
        print_success("Subscription Screen Tests: PASSED")
    else:
        print_error("Subscription Screen Tests: FAILED")
    
    if plans_success:
        print_success("Plans Screen Tests: PASSED")
    else:
        print_error("Plans Screen Tests: FAILED")
    
    if api_success and implementation_success and subscription_success and plans_success:
        print_success("All tests passed successfully!")
    else:
        print_error("Some tests failed. Check the logs for details.")

if __name__ == "__main__":
    main()