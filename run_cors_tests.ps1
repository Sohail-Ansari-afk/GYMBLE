# GYMBLE CORS Testing and Fixing Tool (PowerShell version)

function Show-Menu {
    Clear-Host
    Write-Host "===== GYMBLE CORS Testing and Fixing Tool =====" -ForegroundColor Cyan
    Write-Host
    Write-Host "Please select an option:"
    Write-Host "1. Run comprehensive API tests"
    Write-Host "2. Test CORS configuration"
    Write-Host "3. Fix CORS configuration"
    Write-Host "4. Run all tests and fix"
    Write-Host "5. Exit"
    Write-Host
}

function Run-ApiTests {
    Write-Host
    Write-Host "Running comprehensive API tests..." -ForegroundColor Yellow
    Write-Host
    python run_api_tests.py
    Write-Host
    Write-Host "Press any key to return to the menu..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Test-CorsConfiguration {
    Write-Host
    Write-Host "Testing CORS configuration..." -ForegroundColor Yellow
    Write-Host
    python test_cors_configuration.py
    Write-Host
    Write-Host "Press any key to return to the menu..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Fix-CorsConfiguration {
    Write-Host
    Write-Host "Fixing CORS configuration..." -ForegroundColor Yellow
    Write-Host
    python fix_cors_configuration.py
    Write-Host
    Write-Host "Press any key to return to the menu..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Run-AllTests {
    Write-Host
    Write-Host "Running all tests and fixing CORS configuration..." -ForegroundColor Yellow
    Write-Host

    Write-Host "Step 1: Testing API connection" -ForegroundColor Cyan
    python test_api_connection.py
    Write-Host

    Write-Host "Step 2: Testing Flutter web connection" -ForegroundColor Cyan
    python test_flutter_web_connection.py
    Write-Host

    Write-Host "Step 3: Testing CORS configuration" -ForegroundColor Cyan
    python test_cors_configuration.py
    Write-Host

    Write-Host "Step 4: Fixing CORS configuration" -ForegroundColor Cyan
    python fix_cors_configuration.py
    Write-Host

    Write-Host "All tests completed and fixes applied." -ForegroundColor Green
    Write-Host
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Restart the backend server:"
    Write-Host "   cd backend && python -m uvicorn server:app --reload"
    Write-Host "2. Restart the Flutter web app"
    Write-Host "3. Test the connection again"
    Write-Host
    Write-Host "Press any key to return to the menu..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main menu loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" { Run-ApiTests }
        "2" { Test-CorsConfiguration }
        "3" { Fix-CorsConfiguration }
        "4" { Run-AllTests }
        "5" { break }
        default { 
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Write-Host
            Write-Host "Press any key to continue..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($choice -ne "5")

Write-Host
Write-Host "Thank you for using the GYMBLE CORS Testing and Fixing Tool." -ForegroundColor Cyan
Write-Host