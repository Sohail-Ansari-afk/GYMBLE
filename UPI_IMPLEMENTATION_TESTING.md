# UPI Implementation Testing Guide

## Overview

This guide provides instructions for testing the updated attendance system with the new scan API endpoint and UPI payment functionality with QR code support that has been implemented in the GYMBLE application.

## Part 1: Attendance System Updates

### New API Endpoint

```javascript
POST /api/attendance/scan
Request: {
  memberId: ObjectId,
  qrCode: string,
  timestamp: ISO8601,
  action: "check-in" | "check-out" // Specifies the action to perform
}
Response: {
  success: boolean,
  message: string, // Description of the result
  nextAction: "check-out" | "check-in" // Tells frontend what to expect next
}
```

### Business Logic

- If action is "check-in" and user is not already checked in, a new attendance record is created
- If action is "check-out" and user is already checked in, the existing record is updated with check-out time and duration
- Prevents duplicate check-ins without check-out
- Calculates session duration on check-out using MongoDB date operations

### Testing the Attendance Implementation

#### Prerequisites

- MongoDB server running
- Backend server running (`python -m uvicorn server:app --reload`)
- Frontend server running (`npm run start`)

#### Backend Testing

1. Navigate to the backend directory:
   ```
   cd c:\Users\ka950\Desktop\GYMBLE\GYMBLE\backend
   ```

2. Run the test script:
   ```
   python test_attendance_scan.py
   ```

3. The test script will:
   - Authenticate with the API
   - Get a member ID from the database
   - Get a valid QR code
   - Test check-in operation
   - Wait 5 seconds
   - Test check-out operation
   - Display results

#### Manual Testing

You can also test the API manually using tools like Postman or curl:

1. Get a JWT token by logging in
2. Make a POST request to `/api/attendance/scan` with the following body:
   ```json
   {
     "member_id": "<member-id>",
     "qr_code": "<qr-code-data>",
     "timestamp": "2023-06-15T10:30:00Z",
     "action": "check-in"
   }
   ```
3. Check the response to verify success
4. Make another request with `"action": "check-out"` to test check-out

#### Frontend Integration

The frontend should be updated to use the new API endpoint. Key integration points:

1. Update the attendance scanning component to include the action parameter
2. Use the nextAction field from the response to guide the UI state
3. Display appropriate messages based on the success and message fields

#### Troubleshooting

- If you encounter "Invalid or expired QR code" errors, generate a new QR code
- If you see "Already checked in today" when trying to check in, you need to check out first
- If you see "Not checked in today" when trying to check out, you need to check in first

## Part 2: Frontend Integration

### Frontend Changes

The frontend has been updated to use the new attendance scan API. The following components have been modified:

1. **MobileQRScanner.js**:
   - Updated to use the new `/api/attendance/scan` endpoint
   - Added support for check-in and check-out actions
   - Improved UI to show the next expected action
   - Enhanced error handling

2. **CheckIn.js**:
   - Updated to use the new `/api/attendance/scan` endpoint for staff/owner interface
   - Modified to handle both check-in and check-out operations
   - Updated to display the next action based on API response

### Testing the Frontend Integration

1. Navigate to the frontend directory:
   ```
   cd c:\Users\ka950\Desktop\GYMBLE\GYMBLE\frontend
   ```

2. Run the test script:
   ```
   python test_attendance_scan_frontend.py
   ```

3. The test script will:
   - Authenticate with the API
   - Get a member ID from the database
   - Get a valid QR code
   - Test check-in operation
   - Wait 5 seconds
   - Test check-out operation
   - Offer to open the frontend in a browser for manual testing

### Manual Frontend Testing

1. Log in to the application as a member
2. Navigate to the QR Scanner page
3. Observe the current status and next action displayed
4. Scan a QR code or enter a numeric code to check in
5. Verify the status changes to "Checked In"
6. Scan again to check out
7. Verify the status changes to "Workout Completed" with duration displayed

### Troubleshooting Frontend Issues

- If the QR scanner doesn't work, try using the manual code entry
- If you see "Member ID not found" errors, try logging out and logging back in
- If the status doesn't update after scanning, refresh the page and try again

## Part 3: UPI Payment Implementation

This part explains how to test the UPI payment functionality with QR code support that has been implemented in the GYMBLE application. The implementation includes:

1. Adding QR code support to the UPI payment flow
2. Updating the UPI payment dialog to conditionally use QR code data
3. Modifying the subscription and plans screens to handle QR code data
4. Implementing proper error handling for payment settings

## Test Scripts

Two test scripts have been created to verify the implementation:

1. `test_upi_implementation.py` - Tests the UPI payment implementation
2. `run_upi_implementation_test.ps1` - PowerShell script to run the test and provide a summary

## Prerequisites

Before running the tests, ensure you have:

1. Python 3.6+ installed
2. Required Python packages: `requests`, `Pillow`
3. Backend server running on `http://localhost:8000`

## Running the Tests

### Option 1: Run Using PowerShell Script

To run the test with automatic prerequisite checking, execute the PowerShell script:

```powershell
.\run_upi_implementation_test.ps1
```

This script will:
- Check if Python is installed
- Check if required Python packages are installed
- Check if the backend server is running
- Run the test script
- Provide a summary of the results

### Option 2: Run Python Script Directly

You can also run the test script directly:

```bash
python test_upi_implementation.py
```

## Test Coverage

The test script verifies:

1. **Payment Settings API**
   - GET endpoint for retrieving payment settings
   - PATCH endpoint for updating payment settings with QR code

2. **UPI Payment Widget Implementation**
   - Correct handling of qrCodeData parameter
   - Fallback to generated UPI link when QR code data is not available
   - UpiPaymentDialog correctly passes qrCodeData parameter

3. **Subscription Screen Implementation**
   - Includes qrCodeData parameter in UPI payment dialog
   - Proper error handling with qrCodeData: null for error cases

4. **Plans Screen Implementation**
   - Includes qrCodeData parameter in UPI payment dialog
   - Fetches and uses QR code data from payment settings
   - Proper error handling with qrCodeData: null for error cases

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

## Troubleshooting

If you encounter issues while running the tests:

1. **Backend Server Not Running**
   - Ensure the backend server is running on `http://localhost:8000`
   - Check if the payment settings API endpoints are accessible

2. **Python Package Issues**
   - Install required packages: `pip install requests Pillow`

3. **Permission Issues**
   - If running the PowerShell script fails due to execution policy, run:
     ```powershell
     Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
     ```

## Conclusion

These tests ensure that the QR code support in the UPI payment flow is properly implemented across the application. The implementation now supports:

1. Displaying QR codes provided by the backend
2. Falling back to generated UPI links when QR code data is not available
3. Proper error handling when payment settings cannot be fetched