# UPI Payment Tests Runner

# Colors for terminal output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    } else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header($text) {
    Write-ColorOutput Blue ""
    Write-ColorOutput Blue "================================================"
    Write-ColorOutput Blue "$text"
    Write-ColorOutput Blue "================================================"
    Write-ColorOutput Blue ""
}

function Write-Success($text) {
    Write-ColorOutput Green "✓ $text"
}

function Write-Error($text) {
    Write-ColorOutput Red "✗ $text"
}

function Write-Info($text) {
    Write-ColorOutput Yellow "ℹ $text"
}

# Check if Python is installed
function Check-Python {
    try {
        $pythonVersion = python --version
        Write-Success "Python is installed: $pythonVersion"
        return $true
    } catch {
        Write-Error "Python is not installed or not in PATH"
        return $false
    }
}

# Check if required Python packages are installed
function Check-PythonPackages {
    $requiredPackages = @("requests", "Pillow")
    $allInstalled = $true
    
    foreach ($package in $requiredPackages) {
        try {
            $result = python -c "import $package; print('$package is installed')" 2>$null
            if ($result -match "is installed") {
                Write-Success "$package is installed"
            } else {
                Write-Error "$package is not installed"
                $allInstalled = $false
            }
        } catch {
            Write-Error "$package is not installed"
            $allInstalled = $false
        }
    }
    
    return $allInstalled
}

# Check if backend server is running
function Check-BackendServer {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -Method GET -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "Backend server is running"
            return $true
        } else {
            Write-Error "Backend server returned status code $($response.StatusCode)"
            return $false
        }
    } catch {
        Write-Error "Backend server is not running or not accessible"
        return $false
    }
}

# Check if frontend server is running
function Check-FrontendServer {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8001" -Method GET -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "Frontend server is running"
            return $true
        } else {
            Write-Error "Frontend server returned status code $($response.StatusCode)"
            return $false
        }
    } catch {
        Write-Error "Frontend server is not running or not accessible"
        return $false
    }
}

# Run a test script
function Run-TestScript($scriptPath, $description) {
    Write-Header "RUNNING $description"
    try {
        & python $scriptPath
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$description completed successfully"
            return $true
        } else {
            Write-Error "$description failed with exit code $LASTEXITCODE"
            return $false
        }
    } catch {
        Write-Error "Failed to run ${description} - Error: $($_.Exception.Message)"
        return $false
    }
}

# Main function
function Main {
    Write-Header "UPI PAYMENT TESTS"
    
    # Check prerequisites
    $pythonInstalled = Check-Python
    if (-not $pythonInstalled) {
        Write-Error "Python is required to run the tests"
        return
    }
    
    $packagesInstalled = Check-PythonPackages
    if (-not $packagesInstalled) {
        Write-Error "Required Python packages are not installed"
        Write-Host "Install required packages with: pip install requests Pillow" -ForegroundColor Yellow
        return
    }
    
    $backendRunning = Check-BackendServer
    $frontendRunning = Check-FrontendServer
    
    if (-not $backendRunning) {
        Write-Host "Backend server is not running. Start it before running the tests." -ForegroundColor Yellow
    }
    
    if (-not $frontendRunning) {
        Write-Host "Frontend server is not running. Start it before running the tests." -ForegroundColor Yellow
    }
    
    if (-not ($backendRunning -and $frontendRunning)) {
        $continue = Read-Host "Do you want to continue anyway? (y/n)"
        if ($continue -ne "y") {
            Write-Host "Tests aborted" -ForegroundColor Yellow
            return
        }
    }
    
    # Run tests
    $frontendTestSuccess = Run-TestScript "$PSScriptRoot\frontend_upi_payment_test.py" "Frontend UPI Payment Tests"
    $flutterTestSuccess = Run-TestScript "$PSScriptRoot\flutter_upi_payment_test.py" "Flutter UPI Payment Tests"
    
    # Summary
    Write-Header "TEST SUMMARY"
    if ($frontendTestSuccess) {
        Write-Success "Frontend UPI Payment Tests: PASSED"
    } else {
        Write-Error "Frontend UPI Payment Tests: FAILED"
    }
    
    if ($flutterTestSuccess) {
        Write-Success "Flutter UPI Payment Tests: PASSED"
    } else {
        Write-Error "Flutter UPI Payment Tests: FAILED"
    }
    
    if ($frontendTestSuccess -and $flutterTestSuccess) {
        Write-Success "All tests passed successfully!"
    } else {
        Write-Error "Some tests failed. Check the logs for details."
    }
    
    # Offer to open testing guide
    $openGuide = Read-Host "Do you want to open the UPI Payment Testing guide? (y/n)"
    if ($openGuide -eq "y") {
        if (Test-Path "$PSScriptRoot\PAYMENT_SETTINGS_TESTING.md") {
            Start-Process "$PSScriptRoot\PAYMENT_SETTINGS_TESTING.md"
        } else {
            Write-Error "Testing guide not found"
        }
    }
}

# Run the main function
Main