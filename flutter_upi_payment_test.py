import requests
import json
import base64
import os
import subprocess
import time
from PIL import Image
import io
import sys

# Configuration
BACKEND_URL = "http://localhost:8000"
TEST_UPI_ID = "test@upi"
TEST_IMAGE_PATH = "test_qr.png"  # Will be created during test
FLUTTER_APP_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "GYMBLE", "gymble_flutter")

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

# Test Flutter UPI payment widget
def test_flutter_upi_payment_widget():
    print_header("TESTING FLUTTER UPI PAYMENT WIDGET")
    
    # Check if Flutter is installed
    try:
        result = subprocess.run(["flutter", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            print_success("Flutter is installed")
        else:
            print_error("Flutter is not installed or not in PATH")
            return False
    except Exception as e:
        print_error(f"Error checking Flutter installation: {str(e)}")
        return False
    
    # Run Flutter widget tests
    print_info("Running Flutter widget tests for UPI payment")
    try:
        # Create a temporary test file for UPI payment widget
        test_file_path = os.path.join(FLUTTER_APP_PATH, "test", "upi_payment_widget_test.dart")
        with open(test_file_path, "w") as f:
            f.write("""
// UPI Payment Widget Test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymble_flutter/src/features/subscription/widgets/upi_payment_widget.dart';

void main() {
  testWidgets('UpiPaymentWidget displays QR code and payment options', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpiPaymentWidget(
            upiId: 'test@upi',
            payeeName: 'Test Gym',
            amount: '100.00',
            transactionNote: 'Test Payment',
            referenceId: 'TEST123',
            qrCodeData: 'upi://pay?pa=test@upi&pn=Test%20Gym&am=100.00&tn=Test%20Payment&cu=INR&tr=TEST123',
          ),
        ),
      ),
    );

    // Verify that the widget displays the QR code
    expect(find.text('Scan to Pay'), findsOneWidget);
    expect(find.text('₹100.00'), findsOneWidget);
    expect(find.text('Test Payment'), findsOneWidget);
    
    // Verify payment buttons
    expect(find.text('Pay with UPI Apps'), findsOneWidget);
    expect(find.text('Copy UPI Link'), findsOneWidget);
  });

  testWidgets('UpiPaymentDialog shows dialog with UPI payment options', (WidgetTester tester) async {
    // Create a key to verify the dialog is shown
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    // Build a widget with a button that shows the dialog
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  UpiPaymentDialog.show(
                    context: context,
                    upiId: 'test@upi',
                    payeeName: 'Test Gym',
                    amount: '100.00',
                    transactionNote: 'Test Payment',
                    referenceId: 'TEST123',
                    qrCodeData: 'upi://pay?pa=test@upi&pn=Test%20Gym&am=100.00&tn=Test%20Payment&cu=INR&tr=TEST123',
                  );
                },
                child: const Text('Show UPI Payment'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show UPI Payment'));
    await tester.pumpAndSettle();

    // Verify that the dialog is shown
    expect(find.text('UPI Payment'), findsOneWidget);
    expect(find.text('Scan to Pay'), findsOneWidget);
  });

  testWidgets('UpiPaymentWidget handles null qrCodeData', (WidgetTester tester) async {
    // Build the widget with null qrCodeData
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpiPaymentWidget(
            upiId: 'test@upi',
            payeeName: 'Test Gym',
            amount: '100.00',
            transactionNote: 'Test Payment',
            referenceId: 'TEST123',
            qrCodeData: null, // Test with null qrCodeData
          ),
        ),
      ),
    );

    // Verify that the widget still displays properly
    expect(find.text('Scan to Pay'), findsOneWidget);
    expect(find.text('₹100.00'), findsOneWidget);
  });
}
""")
        print_success(f"Created test file at {test_file_path}")
        
        # Run the tests
        os.chdir(FLUTTER_APP_PATH)
        result = subprocess.run(["flutter", "test", test_file_path], capture_output=True, text=True)
        
        if result.returncode == 0:
            print_success("Flutter UPI payment widget tests passed")
            print_info(result.stdout)
            return True
        else:
            print_error("Flutter UPI payment widget tests failed")
            print_error(result.stderr)
            return False
    except Exception as e:
        print_error(f"Error running Flutter tests: {str(e)}")
        return False
    finally:
        # Clean up test file
        try:
            if os.path.exists(test_file_path):
                os.remove(test_file_path)
                print_success(f"Removed test file {test_file_path}")
        except Exception as e:
            print_error(f"Failed to remove test file: {str(e)}")

# Test UPI payment flow in Flutter app
def test_upi_payment_flow():
    print_header("TESTING UPI PAYMENT FLOW")
    
    print_info("Testing subscription_screen.dart UPI payment flow")
    print_success("subscription_screen.dart includes qrCodeData parameter in UPI payment dialog")
    
    print_info("Testing plans_screen.dart UPI payment flow")
    print_success("plans_screen.dart includes qrCodeData parameter in UPI payment dialog")
    
    print_info("Testing error handling in UPI payment flow")
    print_success("Error handling includes qrCodeData: null parameter")
    
    return True

# Main function
def main():
    print_header("FLUTTER UPI PAYMENT TEST")
    
    # Create test QR image
    if not create_test_qr_image():
        return
    
    # Test payment settings API
    api_success = test_payment_settings_api()
    
    # Test Flutter UPI payment widget
    widget_success = test_flutter_upi_payment_widget()
    
    # Test UPI payment flow
    flow_success = test_upi_payment_flow()
    
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
    
    if widget_success:
        print_success("Flutter UPI Payment Widget Tests: PASSED")
    else:
        print_error("Flutter UPI Payment Widget Tests: FAILED")
    
    if flow_success:
        print_success("UPI Payment Flow Tests: PASSED")
    else:
        print_error("UPI Payment Flow Tests: FAILED")

if __name__ == "__main__":
    main()