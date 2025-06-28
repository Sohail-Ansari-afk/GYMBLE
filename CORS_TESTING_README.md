# CORS Testing and Fixing Guide for GYMBLE

This guide explains how to diagnose and fix CORS (Cross-Origin Resource Sharing) issues between the Flutter web app and the backend API server.

## Background

The Flutter web app running on `http://localhost:52914` is unable to fetch gym data from the backend API at `http://localhost:8000/api/gyms/all`. This is likely due to CORS restrictions preventing the web browser from making cross-origin requests.

## Diagnostic Tools

This repository includes several Python scripts to help diagnose and fix CORS issues:

1. **test_api_connection.py** - Tests basic API connectivity and CORS configuration
2. **test_flutter_web_connection.py** - Simulates how the Flutter web app connects to the backend
3. **test_cors_configuration.py** - Specifically tests CORS headers for different origins
4. **fix_cors_configuration.py** - Automatically updates the CORS configuration in server.py
5. **run_api_tests.py** - Runs multiple tests and provides a comprehensive analysis

## How to Use

### 1. Run the Comprehensive Test Suite

```bash
python run_api_tests.py
```

This will run multiple tests and provide a detailed analysis of any connection issues.

### 2. Test CORS Configuration

```bash
python test_cors_configuration.py
```

This script specifically tests if the backend server's CORS configuration allows requests from the Flutter web app origin.

### 3. Fix CORS Configuration

```bash
python fix_cors_configuration.py
```

This script will automatically update the CORS configuration in server.py to allow requests from the Flutter web app.

## Common CORS Issues and Solutions

### 1. Missing Origin in ALLOWED_ORIGINS

**Problem:** The Flutter web app's origin (`http://localhost:52914`) is not included in the `ALLOWED_ORIGINS` list in server.py.

**Solution:** Add the following origins to the `ALLOWED_ORIGINS` list in server.py:

```python
ALLOWED_ORIGINS = [
    # ... existing origins ...
    "http://localhost:52914",      # Flutter web app port
    "http://127.0.0.1:52914",      # Alternative localhost
    "http://localhost:*",          # Any localhost port
    "http://127.0.0.1:*"           # Any 127.0.0.1 port
]
```

### 2. CORS Middleware Not Properly Configured

**Problem:** The CORS middleware is not properly configured in the FastAPI app.

**Solution:** Ensure the CORS middleware is added to the app with the correct parameters:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
)
```

### 3. Flutter Web App Using Incorrect API URL

**Problem:** The Flutter web app is using an incorrect API URL.

**Solution:** Check the `.env` file in the Flutter app and ensure `WEB_API_BASE_URL` is set correctly:

```
WEB_API_BASE_URL=http://localhost:8000/api
```

## Troubleshooting

### Browser Console Errors

Check the browser console for CORS-related errors when running the Flutter web app. Common errors include:

- `Access to XMLHttpRequest at 'http://localhost:8000/api/gyms/all' from origin 'http://localhost:52914' has been blocked by CORS policy`
- `No 'Access-Control-Allow-Origin' header is present on the requested resource`

### Backend Server Logs

Check the backend server logs for any errors related to CORS or the API endpoints. Look for:

- `OPTIONS` requests that are failing
- Error messages related to CORS configuration
- Issues with the `/api/gyms/all` endpoint

## After Fixing

After applying the fixes:

1. Restart the backend server:
   ```bash
   cd backend && python -m uvicorn server:app --reload
   ```

2. Restart the Flutter web app

3. Test the connection again to ensure the issue is resolved

## Additional Resources

- [FastAPI CORS Documentation](https://fastapi.tiangolo.com/tutorial/cors/)
- [MDN Web Docs: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Flutter Web HTTP Requests](https://flutter.dev/docs/development/data-and-backend/networking)