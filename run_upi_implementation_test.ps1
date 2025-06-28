# UPI Implementation Test Runner

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
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
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

# Main function
function Main {
    Write-Header "UPI IMPLEMENTATION TEST"
    
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
    
    if (-not $backendRunning) {
        Write-Host "Backend server is not running. Start it before running the tests." -ForegroundColor Yellow
        $continue = Read-Host "Do you want to continue anyway? (y/n)"
        if ($continue -ne "y") {
            Write-Host "Tests aborted" -ForegroundColor Yellow
            return
        }
    }
    
    # Run the test script
    Write-Header "RUNNING UPI IMPLEMENTATION TEST"
    try {
        & python "$PSScriptRoot\test_upi_implementation.py"
        if ($LASTEXITCODE -eq 0) {
            Write-Success "UPI implementation test completed successfully"
        } else {
            Write-Error "UPI implementation test failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Error "Failed to run UPI implementation test - Error: $($_.Exception.Message)"
    }
}

# Run the main function
Main