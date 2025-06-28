# Payment Settings Implementation

## Overview

This implementation adds a new "Payment Settings" section to the GYMBLE application's owner dashboard. The feature allows gym owners to set up their UPI payment details and upload a QR code for contactless payments.

## Features

- UPI ID input field with validation
- QR code image uploader with drag-and-drop functionality
- Image preview and delete options
- Backend API endpoints for storing and retrieving payment settings

## Implementation Details

### Backend Changes

1. Added a new `upi_id` field to the `Gym` and `GymCreate` Pydantic models
2. Created two new API endpoints:
   - `GET /api/gym/payment-settings` - Retrieves current payment settings
   - `PATCH /api/gym/payment-settings` - Updates payment settings
3. Added a new `PaymentSettingsUpdate` Pydantic model for handling update requests

### Frontend Changes

1. Created a new `PaymentSettings.js` component with React and Tailwind CSS
2. Added `react-dropzone` for handling file uploads
3. Updated `App.js` to include the new component in navigation and routing

## Testing

We've created several testing resources to verify the implementation:

### 1. Backend API Test Script

- **File**: `backend/test_payment_settings.py`
- **Purpose**: Tests the backend API endpoints for payment settings
- **Usage**: Run `python backend/test_payment_settings.py` from the project root

### 2. Frontend Component Test

- **File**: `frontend/src/components/PaymentSettings.test.js`
- **Purpose**: Unit tests for the React component
- **Usage**: Run `npm test -- --testPathPattern=PaymentSettings.test.js` from the frontend directory

### 3. Standalone QR Upload Test Page

- **File**: `frontend/public/test-qr-upload.html`
- **Purpose**: Tests QR code upload functionality independently
- **Usage**: Open `http://localhost:3000/test-qr-upload.html` when the frontend server is running

### 4. Test Runner Scripts

- **Files**: 
  - `test_payment_settings.ps1` (PowerShell for Windows)
  - `test_payment_settings.sh` (Bash for Linux/macOS)
- **Purpose**: Automate running all tests in sequence
- **Usage**: 
  - Windows: Run `./test_payment_settings.ps1` from PowerShell
  - Linux/macOS: Run `bash ./test_payment_settings.sh` from terminal

### 5. Testing Guide

- **File**: `PAYMENT_SETTINGS_TESTING.md`
- **Purpose**: Detailed instructions for manual and automated testing
- **Usage**: Open in any markdown viewer or text editor

## How to Use

1. Start the backend server:
   ```
   cd backend
   python server.py
   ```

2. Start the frontend development server:
   ```
   cd frontend
   npm start
   ```
   or
   ```
   cd frontend
   yarn start
   ```

3. Navigate to the application in your browser at `http://localhost:3000`

4. Log in as a gym owner

5. Click on "payment-settings" in the navigation menu

6. Enter your UPI ID and upload a QR code image

7. Click "Save Settings" to store your payment information

## Troubleshooting

- If you encounter issues with the backend API, check that the server is running on port 8001
- If the frontend component doesn't appear, verify that you've logged in as a gym owner
- For detailed troubleshooting steps, refer to the `PAYMENT_SETTINGS_TESTING.md` file

## Future Enhancements

Possible future improvements to this feature:

1. Support for multiple payment methods beyond UPI
2. QR code generation based on UPI ID
3. Payment history and analytics
4. Integration with payment gateways for real-time status

---

This implementation completes the requested feature to add a Payment Settings section to the owner dashboard with UPI ID input and QR code management.