# GYMBLE CORS Troubleshooting Guide

## Overview

This guide will help you diagnose and fix Cross-Origin Resource Sharing (CORS) issues between your Flutter web application and the FastAPI backend server. CORS is a security feature implemented by browsers that restricts web pages from making requests to a different domain than the one that served the web page.

## Symptoms of CORS Issues

- Flutter web app cannot fetch data from the backend API
- Browser console shows errors like:
  - "Access to fetch at 'http://localhost:8000/api/gyms/all' from origin 'http://localhost:52914' has been blocked by CORS policy"
  - "No 'Access-Control-Allow-Origin' header is present on the requested resource"
- API requests work fine when tested with tools like Postman or curl, but fail in the browser

## Diagnostic Tools

We've created several tools to help you diagnose and fix CORS issues:

### 1. CORS Diagnostic Tool (Python)

**File:** `cors_diagnostic_tool.py`

This is the most comprehensive tool that:
- Checks if the backend server is running
- Tests API endpoints with and without Origin headers
- Tests OPTIONS requests (CORS preflight)
- Analyzes your server.py file to check CORS configuration
- Can automatically fix CORS configuration issues
- Generates recommendations
- Creates a detailed log file

**Usage:**
```bash
python cors_diagnostic_tool.py
```

### 2. Backend API Test (Python)

**File:** `test_backend_api.py`

This tool provides a detailed analysis of your backend API and CORS configuration:
- Tests all endpoints
- Tests CORS for multiple origins
- Analyzes server.py
- Generates recommendations

**Usage:**
```bash
python test_backend_api.py
```

### 3. CORS Test HTML Page

**File:** `cors_test.html`

A browser-based tool that allows you to:
- Test API requests using Fetch API and XMLHttpRequest
- Test OPTIONS requests
- See detailed response headers and CORS information
- Customize the API endpoint to test

**Usage:**
Open `cors_test.html` in your web browser

### 4. PowerShell Menu Script

**File:** `run_cors_tests.ps1`

A menu-driven PowerShell script that provides easy access to all testing tools:
- Run comprehensive API tests
- Test CORS configuration
- Fix CORS configuration
- Run all tests and fixes

**Usage:**
Right-click the file and select "Run with PowerShell" or open PowerShell and run:
```powershell
.\run_cors_tests.ps1
```

## Common CORS Issues and Solutions

### 1. Missing or Incorrect ALLOWED_ORIGINS

**Problem:** The Flutter web app's origin is not included in the ALLOWED_ORIGINS list in server.py.

**Solution:** Update the ALLOWED_ORIGINS list in server.py to include:
```python
ALLOWED_ORIGINS = [
    "http://localhost:52914",  # Flutter web app origin
    "http://127.0.0.1:52914",  # Alternative Flutter web app origin
    "http://localhost:*",      # Any localhost port
    "http://127.0.0.1:*"       # Any 127.0.0.1 port
]
```

### 2. Missing CORSMiddleware

**Problem:** The CORSMiddleware is not configured in the FastAPI app.

**Solution:** Add the following code to server.py:
```python
from fastapi.middleware.cors import CORSMiddleware

ALLOWED_ORIGINS = ["http://localhost:52914", "http://127.0.0.1:52914", "http://localhost:*", "http://127.0.0.1:*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 3. Incorrect CORSMiddleware Configuration

**Problem:** The CORSMiddleware is configured but with incorrect parameters.

**Solution:** Ensure the CORSMiddleware is configured with:
- `allow_origins` set to include the Flutter web app origin
- `allow_credentials` set to True if you're using cookies or authentication
- `allow_methods` and `allow_headers` set to ["*"] to allow all methods and headers

## Step-by-Step Troubleshooting

1. **Verify the backend server is running:**
   ```bash
   cd backend
   python -m uvicorn server:app --reload
   ```

2. **Run the CORS diagnostic tool:**
   ```bash
   python cors_diagnostic_tool.py
   ```

3. **If issues are found, either:**
   - Let the diagnostic tool fix them automatically (recommended)
   - Manually update server.py based on the recommendations

4. **Restart the backend server after making changes**

5. **Run the diagnostic tool again to verify the fixes**

6. **Test the Flutter web app**

## Additional Resources

- [FastAPI CORS Documentation](https://fastapi.tiangolo.com/tutorial/cors/)
- [MDN CORS Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Flutter Web Networking](https://flutter.dev/docs/development/platform-integration/web)

## Troubleshooting Tips

- Always check the browser console (F12) for detailed error messages
- Remember that CORS is enforced by the browser, not the server
- The OPTIONS request (preflight) must succeed before the actual request is sent
- If using authentication, ensure `allow_credentials` is set to True
- If all else fails, try using a CORS browser extension temporarily for testing

## Need More Help?

If you're still experiencing CORS issues after following this guide, check:

1. Network/firewall settings that might be blocking requests
2. Proxy configurations
3. SSL/HTTPS mismatches (mixing HTTP and HTTPS)
4. Custom headers that might require additional CORS configuration

---

Created by GYMBLE Development Team