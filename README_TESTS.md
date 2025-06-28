# GYMBLE Authentication Testing

This directory contains test scripts for testing the authentication system of the GYMBLE application. These scripts test both the backend API endpoints and the Flutter implementation of the authentication service.

## Available Test Scripts

### 1. `test_auth_api.py`

This script tests the backend API authentication endpoints, including:

- User registration (`/auth/register`)
- User login (`/auth/login`)
- Token validation (`/auth/me`)
- Gym creation (`/gyms`)
- Plan creation (`/plans`)
- Member registration (`/auth/register-member`)

### 2. `test_flutter_auth.py`

This script tests both the backend API and the Flutter implementation of the authentication service. It includes all the tests from `test_auth_api.py` plus additional tests for the Flutter `AuthService` class.

## Prerequisites

- Python 3.6 or higher
- `requests` library (`pip install requests`)
- Backend server running on `http://localhost:8000`
- For Flutter tests: Flutter SDK installed and configured

## Running the Tests

### Testing Backend API Only

1. Make sure the backend server is running on `http://localhost:8000`
2. Run the following command:

```bash
python test_auth_api.py
```

### Testing Backend API and Flutter Implementation

1. Make sure the backend server is running on `http://localhost:8000`
2. Make sure Flutter SDK is installed and configured
3. Run the following command:

```bash
python test_flutter_auth.py
```

## Test Output

The test scripts will output detailed information about each test, including:

- HTTP status codes
- Response data
- Success or failure messages

Example output:

```
==========================================
 Testing User Registration 
==========================================
Status Code: 201
Registration successful!
Access Token: eyJhbGciOiJIUzI1NiIs...
User ID: 60f1e5b3e6b3f3a3c8f3e5b3
User Email: test_user_1626456789@example.com
User Role: owner

==========================================
 Testing User Login 
==========================================
Status Code: 200
Login successful!
Access Token: eyJhbGciOiJIUzI1NiIs...
User ID: 60f1e5b3e6b3f3a3c8f3e5b3
User Email: test_user_1626456789@example.com
User Role: owner
```

## Notes

- The test scripts generate unique email addresses for each test run to avoid conflicts with existing users.
- If any test fails, the script will stop and display an error message.
- For the Flutter tests, a temporary Dart file is created and then removed after the test is complete.

## Troubleshooting

- If you encounter connection errors, make sure the backend server is running on `http://localhost:8000`.
- If you encounter authentication errors, check that the API endpoints are correctly implemented according to the specification.
- For Flutter tests, make sure Flutter SDK is installed and configured correctly.