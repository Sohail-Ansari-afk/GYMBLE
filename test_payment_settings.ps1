# PowerShell script to test the Payment Settings implementation

# Set colors for output
$Green = "\033[92m"
$Red = "\033[91m"
$Yellow = "\033[93m"
$Blue = "\033[94m"
$EndColor = "\033[0m"

function Write-ColoredOutput {
    param (
        [string]$Text,
        [string]$Color
    )
    Write-Host "$Color$Text$EndColor"
}

function Write-Header {
    param ([string]$Text)
    Write-Host ""
    Write-ColoredOutput ("=" * 70) $Blue
    Write-ColoredOutput $Text.PadLeft(35 + ($Text.Length / 2)) $Blue
    Write-ColoredOutput ("=" * 70) $Blue
    Write-Host ""
}

function Test-Command {
    param (
        [string]$Command,
        [string]$Description,
        [string]$WorkingDirectory
    )
    
    Write-ColoredOutput "Running: $Description" $Yellow
    
    try {
        if ($WorkingDirectory) {
            Push-Location $WorkingDirectory
        }
        
        Invoke-Expression $Command
        $success = $?
        
        if ($WorkingDirectory) {
            Pop-Location
        }
        
        if ($success) {
            Write-ColoredOutput "✓ $Description completed successfully" $Green
            return $true
        } else {
            Write-ColoredOutput "✗ $Description failed" $Red
            return $false
        }
    } catch {
        Write-ColoredOutput "✗ Error running $Description: $_" $Red
        if ($WorkingDirectory) {
            Pop-Location
        }
        return $false
    }
}

# Main script
Write-Header "PAYMENT SETTINGS IMPLEMENTATION TEST"

# Check if backend server is running
Write-ColoredOutput "Checking if backend server is running..." $Yellow
$backendRunning = $false

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/docs" -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        $backendRunning = $true
        Write-ColoredOutput "✓ Backend server is running" $Green
    }
} catch {
    Write-ColoredOutput "✗ Backend server is not running" $Red
    Write-ColoredOutput "Please start the backend server before running tests" $Yellow
    exit 1
}

# Check if frontend server is running
Write-ColoredOutput "Checking if frontend server is running..." $Yellow
$frontendRunning = $false

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        $frontendRunning = $true
        Write-ColoredOutput "✓ Frontend server is running" $Green
    }
} catch {
    Write-ColoredOutput "✗ Frontend server is not running" $Red
    Write-ColoredOutput "Please start the frontend server before running tests" $Yellow
    exit 1
}

# Run backend tests
Write-Header "BACKEND TESTS"
$backendTestSuccess = Test-Command -Command "python test_payment_settings.py" -Description "Backend API tests" -WorkingDirectory "$PSScriptRoot\GYMBLE\backend"

# Run frontend tests
Write-Header "FRONTEND TESTS"
$frontendTestSuccess = Test-Command -Command "npm test -- --testPathPattern=PaymentSettings.test.js" -Description "Frontend component tests" -WorkingDirectory "$PSScriptRoot\GYMBLE\frontend"

# Summary
Write-Header "TEST SUMMARY"

if ($backendTestSuccess) {
    Write-ColoredOutput "✓ Backend tests: PASSED" $Green
} else {
    Write-ColoredOutput "✗ Backend tests: FAILED" $Red
}

if ($frontendTestSuccess) {
    Write-ColoredOutput "✓ Frontend tests: PASSED" $Green
} else {
    Write-ColoredOutput "✗ Frontend tests: FAILED" $Red
}

Write-Host ""
Write-ColoredOutput "For more details, please refer to the PAYMENT_SETTINGS_TESTING.md file." $Yellow
Write-Host ""

# Open the testing guide
$openGuide = Read-Host "Would you like to open the testing guide? (y/n)"
if ($openGuide -eq "y") {
    Invoke-Item "$PSScriptRoot\GYMBLE\PAYMENT_SETTINGS_TESTING.md"
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")