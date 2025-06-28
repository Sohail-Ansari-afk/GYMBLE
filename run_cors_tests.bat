@echo off
echo ===== GYMBLE CORS Testing and Fixing Tool =====
echo.

:menu
echo Please select an option:
echo 1. Run comprehensive API tests
echo 2. Test CORS configuration
echo 3. Fix CORS configuration
echo 4. Run all tests and fix
echo 5. Exit
echo.

set /p choice=Enter your choice (1-5): 

if "%choice%"=="1" goto run_api_tests
if "%choice%"=="2" goto test_cors
if "%choice%"=="3" goto fix_cors
if "%choice%"=="4" goto run_all
if "%choice%"=="5" goto end

echo Invalid choice. Please try again.
echo.
goto menu

:run_api_tests
echo.
echo Running comprehensive API tests...
echo.
python run_api_tests.py
echo.
echo Press any key to return to the menu...
pause > nul
goto menu

:test_cors
echo.
echo Testing CORS configuration...
echo.
python test_cors_configuration.py
echo.
echo Press any key to return to the menu...
pause > nul
goto menu

:fix_cors
echo.
echo Fixing CORS configuration...
echo.
python fix_cors_configuration.py
echo.
echo Press any key to return to the menu...
pause > nul
goto menu

:run_all
echo.
echo Running all tests and fixing CORS configuration...
echo.

echo Step 1: Testing API connection
python test_api_connection.py
echo.

echo Step 2: Testing Flutter web connection
python test_flutter_web_connection.py
echo.

echo Step 3: Testing CORS configuration
python test_cors_configuration.py
echo.

echo Step 4: Fixing CORS configuration
python fix_cors_configuration.py
echo.

echo All tests completed and fixes applied.
echo.
echo Next steps:
echo 1. Restart the backend server:
echo    cd backend ^&^& python -m uvicorn server:app --reload
echo 2. Restart the Flutter web app
echo 3. Test the connection again
echo.
echo Press any key to return to the menu...
pause > nul
goto menu

:end
echo.
echo Thank you for using the GYMBLE CORS Testing and Fixing Tool.
echo.