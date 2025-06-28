# CORS Troubleshooting Guide for GYMBLE

## Overview

This guide provides steps to troubleshoot Cross-Origin Resource Sharing (CORS) issues in the GYMBLE application, particularly when the Flutter web app is unable to connect to the backend API.

## Recent Changes Made

The following changes have been implemented to fix CORS issues:

1. **Enhanced ApiService in Flutter app**:
   - Added web-safe HTTP client methods for handling CORS in web environment
   - Added detailed logging for debugging API responses
   - Added Origin header for web requests

2. **Updated index.html**:
   - Added CORS handling script
   - Set Flutter web renderer to "html" mode
   - Added event listeners for better CORS debugging

3. **Created CORS testing tools**:
   - Added `cors_test.html` for direct browser testing

## Troubleshooting Steps

### 1. Verify Backend CORS Configuration

Ensure the FastAPI backend has proper CORS middleware configuration:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:52914", "http://localhost:3000", "http://localhost:8000"],  # Add your Flutter web app origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 2. Check Flutter Web Configuration

- Ensure the `.env` file has the correct `WEB_API_BASE_URL` setting
- Verify that the Flutter web app is using the correct API URL

### 3. Use the CORS Test Tool

1. Start your backend server
2. Open `gymble_flutter/web/cors_test.html` in a browser
3. Click the test buttons to check if the API is accessible
4. Review the CORS headers in the response

### 4. Check Browser Console

Open the browser developer tools (F12) and check the console for CORS-related errors:

- Look for messages like "Access to fetch at ... from origin ... has been blocked by CORS policy"
- Check the Network tab to see the actual requests and responses

### 5. Try Different Flutter Web Renderers

If issues persist, try different Flutter web renderers:

```bash
# Run with HTML renderer
flutter run -d chrome --web-renderer html

# Run with CanvasKit renderer
flutter run -d chrome --web-renderer canvaskit
```

### 6. Restart Services

Sometimes a simple restart can fix CORS issues:

1. Stop the backend server and Flutter web app
2. Clear browser cache (or use incognito mode)
3. Restart the backend server
4. Restart the Flutter web app

## Common CORS Issues and Solutions

### Issue: Missing CORS Headers

**Solution**: Ensure the backend is sending the correct CORS headers:
- `Access-Control-Allow-Origin`
- `Access-Control-Allow-Methods`
- `Access-Control-Allow-Headers`
- `Access-Control-Allow-Credentials` (if using credentials)

### Issue: Preflight Requests Failing

**Solution**: Ensure the backend properly handles OPTIONS requests.

### Issue: Credentials Not Working

**Solution**: If using credentials, ensure:
- Backend has `allow_credentials=True`
- Frontend uses `credentials: 'include'` in fetch requests
- `Access-Control-Allow-Origin` cannot be `*` when using credentials

## Additional Resources

- [MDN CORS Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [FastAPI CORS Documentation](https://fastapi.tiangolo.com/tutorial/cors/)
- [Flutter Web Networking](https://flutter.dev/docs/development/platform-integration/web)