# Payment Settings Testing Guide

This guide provides instructions for testing the newly implemented Payment Settings feature in the GYMBLE application.

## Overview

The Payment Settings feature allows gym owners to:
- Set their UPI ID for receiving payments
- Upload a QR code image for contactless payments
- View and manage their payment settings

## Testing the Backend API

### Prerequisites
- Python 3.11 or higher
- The backend server running on port 8001
- PIL (Pillow) library installed (`pip install pillow`)

### Running the Backend Test Script

1. Navigate to the backend directory:
   ```
   cd GYMBLE/backend
   ```

2. Run the test script:
   ```
   python test_payment_settings.py
   ```

3. When prompted, enter your JWT token or provide your email and password to authenticate.

4. The script will test both API endpoints:
   - `GET /api/gym/payment-settings` - Retrieves current payment settings
   - `PATCH /api/gym/payment-settings` - Updates payment settings

5. The test results will be displayed in the console with color-coded success/failure indicators.

### Expected Results

- The script should create a test QR code image, upload it to the server, and then clean up after itself.
- Both API endpoints should return 200 status codes.
- The updated UPI ID and QR code should be correctly stored and retrieved.

## Testing the Frontend Component

### Prerequisites
- Node.js and npm/yarn installed
- The frontend development server running on port 3000

### Manual Testing

1. Log in to the GYMBLE application as a gym owner.

2. Navigate to the Payment Settings page using the navigation menu.

3. Test the following functionality:
   - Entering a valid UPI ID (e.g., `name@upi`)
   - Entering an invalid UPI ID and verifying validation errors
   - Uploading a QR code image by drag-and-drop
   - Uploading a QR code image by clicking the upload area
   - Previewing the uploaded QR code
   - Removing the QR code
   - Saving the settings and verifying success message
   - Refreshing the page and verifying that settings persist

### Running Frontend Unit Tests

1. Navigate to the frontend directory:
   ```
   cd GYMBLE/frontend
   ```

2. Run the Jest tests:
   ```
   npm test -- --testPathPattern=PaymentSettings.test.js
   ```
   or with yarn:
   ```
   yarn test --testPathPattern=PaymentSettings.test.js
   ```

3. All tests should pass, verifying that the component:
   - Renders correctly
   - Loads existing settings
   - Handles UPI ID input changes
   - Handles QR code uploads
   - Handles form submission
   - Displays appropriate error messages
   - Allows QR code deletion

## Integration Testing

To perform a complete end-to-end test:

1. Start both the backend and frontend servers.

2. Log in as a gym owner.

3. Navigate to Payment Settings.

4. Update the UPI ID and QR code.

5. Save the settings.

6. Log out and log back in to verify persistence.

7. Check the MongoDB database to confirm that the data is correctly stored:
   ```javascript
   db.gyms.findOne({"_id": ObjectId("your_gym_id")}, {"upi_id": 1, "qr_code_data": 1})
   ```

## Troubleshooting

### Backend Issues

- If the API returns 401 Unauthorized, your JWT token may have expired. Log in again to get a new token.
- If the API returns 500 Internal Server Error, check the backend logs for details.

### Frontend Issues

- If the QR code upload fails, ensure the image is in a supported format (PNG, JPG, JPEG).
- If the form submission fails, check the browser console for error messages.
- If the component doesn't render, ensure that the route is correctly configured in App.js.

## Reporting Issues

If you encounter any issues during testing, please document:

1. The specific action that caused the issue
2. Any error messages displayed
3. The expected vs. actual behavior
4. Browser/environment details

---

This testing guide was created to help verify the Payment Settings implementation. If you have any questions or need assistance, please contact the development team.