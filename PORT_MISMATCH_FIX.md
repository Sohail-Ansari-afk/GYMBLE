# Payment Settings Port Mismatch Fix

## The Issue

The payment settings test scripts are failing because of a port mismatch:

1. The test scripts (`test_payment_settings.py`, `test_payment_settings.ps1`, and `test_payment_settings.sh`) are configured to connect to `http://localhost:8001`
2. But the backend server is actually running on `http://localhost:8000` (as shown in the terminal output)

## Evidence

### Test Scripts Configuration

- In `test_payment_settings.py`:
  ```python
  BASE_URL = "http://localhost:8001"  # Incorrect port
  ```

- In `test_payment_settings.ps1`:
  ```powershell
  $response = Invoke-WebRequest -Uri "http://localhost:8001/docs"  # Incorrect port
  ```

- In `test_payment_settings.sh`:
  ```bash
  if curl -s http://localhost:8001/docs -o /dev/null;  # Incorrect port
  ```

### Actual Server Configuration

The server is running on port 8000 as shown in the terminal output:

```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

## Solution Options

### Option 1: Update Test Scripts to Use Port 8000 (Recommended)

Run the provided fix script to update all test scripts:

```powershell
.\fix_payment_settings_tests.ps1
```

This script will automatically update the port in all three test files.

### Option 2: Run the Server on Port 8001

Alternatively, you can restart your server with port 8001 specified:

```
python -m uvicorn server:app --reload --port 8001
```

## Additional Authentication Note

When running the test script, you'll be prompted for authentication. Make sure to:

1. Use a valid email and password for a gym owner account
2. Or provide a valid JWT token if you already have one

The test script is asking for a JWT token (the one that's generated after login), not the secret key used to sign tokens.

## After Fixing

After applying either fix, you should be able to run the test scripts successfully:

```powershell
# For PowerShell
.\GYMBLE\test_payment_settings.ps1

# For Python directly
python .\GYMBLE\backend\test_payment_settings.py
```