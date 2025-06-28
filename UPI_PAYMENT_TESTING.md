# UPI Payment Testing Guide

## Overview

This guide explains how to test the UPI payment functionality with QR code support that has been implemented in the GYMBLE application. The implementation includes:

1. Adding QR code support to the UPI payment flow
2. Updating the UPI payment dialog to conditionally use QR code data
3. Modifying the subscription and plans screens to handle QR code data
4. Implementing proper error handling for payment settings

## Test Scripts

Three test scripts have been created to verify the implementation:

1. `frontend_upi_payment_test.py` - Tests the frontend React component for payment settings
2. `flutter_upi_payment_test.py` - Tests the Flutter UPI payment widget and flow
3. `run_upi_payment_tests.ps1` - PowerShell script to run both tests and provide a summary

## Prerequisites

Before running the tests, ensure you have:

1. Python 3.6+ installed
2. Required Python packages: `requests`, `Pillow`
3. Backend server running on `http://localhost:8000`
4. Frontend server running on `http://localhost:8001`
5. Flutter SDK installed (for Flutter tests)

## Running the Tests

### Option 1: Run All Tests

To run all tests at once, execute the PowerShell script:

```powershell
.\run_upi_payment_tests.ps1
```

This script will:
- Check if all prerequisites are met
- Run both test scripts
- Provide a summary of the results

### Option 2: Run Individual Tests

You can also run each test script individually:

```bash
# Test frontend UPI payment functionality
python frontend_upi_payment_test.py

# Test Flutter UPI payment functionality
python flutter_upi_payment_test.py
```

## Test Coverage

### Frontend Tests

The frontend test script verifies:

1. Payment settings API endpoints (GET and PATCH)
2. UPI ID validation and storage
3. QR code upload, storage, and display
4. QR code removal functionality
5. Component rendering and user interactions

### Flutter Tests

The Flutter test script verifies:

1. UPI payment widget rendering with and without QR code data
2. UPI payment dialog functionality
3. QR code display in the payment flow
4. Error handling when payment settings are unavailable
5. Integration with payment settings provider

## Implementation Details

### Changes Made

1. **UPI Payment Widget**
   - Added `qrCodeData` parameter to conditionally use provided QR code data
   - Implemented fallback to generated UPI link when QR code data is not available

2. **Subscription Screen**
   - Updated `_showUpiPayment` method to include `qrCodeData` parameter
   - Added error handling with `qrCodeData: null` for error cases

3. **Plans Screen**
   - Refactored `_showUpiPaymentDialog` to fetch and use QR code data from payment settings
   - Implemented error handling for payment settings retrieval
   - Added proper imports for payment settings provider

### Testing Approach

The tests use a combination of:

1. **API Testing**: Verifying backend endpoints for payment settings
2. **Component Testing**: Checking UI components render correctly
3. **Integration Testing**: Ensuring components work together properly
4. **Error Handling**: Verifying graceful degradation when errors occur

## Troubleshooting

If tests fail, check the following:

1. Ensure backend and frontend servers are running
2. Verify that required Python packages are installed
3. Check that the test QR image can be created and read
4. Ensure Flutter SDK is properly installed (for Flutter tests)
5. Check network connectivity to API endpoints

## Next Steps

After verifying the implementation with these tests, consider:

1. Adding more comprehensive UI tests
2. Implementing end-to-end payment flow tests
3. Adding performance testing for QR code generation and display
4. Testing on different device sizes and orientations