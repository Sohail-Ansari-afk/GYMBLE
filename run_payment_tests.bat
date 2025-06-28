@echo off
echo Running Payment Settings Tests with Fixed Port Configuration
echo.

REM Run the PowerShell fix script
powershell -ExecutionPolicy Bypass -File "%~dp0fix_payment_settings_tests.ps1"

echo.
echo Running the payment settings tests...
echo.

REM Run the PowerShell test script
powershell -ExecutionPolicy Bypass -File "%~dp0GYMBLE\test_payment_settings.ps1"

echo.
echo Test execution complete.
echo.

pause