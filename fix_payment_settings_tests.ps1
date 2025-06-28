# PowerShell script to fix the port configuration in payment settings test scripts

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

# Main script
Write-Header "PAYMENT SETTINGS TEST FIX"

# Fix the Python test script
Write-ColoredOutput "Checking Python test script..." $Yellow
$pythonTestPath = "$PSScriptRoot\GYMBLE\backend\test_payment_settings.py"

if (Test-Path $pythonTestPath) {
    $content = Get-Content $pythonTestPath -Raw
    
    # Check if the BASE_URL is set to port 8001
    if ($content -match 'BASE_URL = "http://localhost:8001"') {
        Write-ColoredOutput "Found incorrect port (8001) in Python test script" $Yellow
        
        # Replace with port 8000
        $newContent = $content -replace 'BASE_URL = "http://localhost:8001"', 'BASE_URL = "http://localhost:8000"'
        Set-Content -Path $pythonTestPath -Value $newContent
        
        Write-ColoredOutput "✓ Updated Python test script to use port 8000" $Green
    } elseif ($content -match 'BASE_URL = "http://localhost:8000"') {
        Write-ColoredOutput "✓ Python test script already using correct port (8000)" $Green
    } else {
        Write-ColoredOutput "? Could not find BASE_URL setting in Python test script" $Yellow
    }
} else {
    Write-ColoredOutput "✗ Could not find Python test script at $pythonTestPath" $Red
}

# Fix the PowerShell test script
Write-ColoredOutput "Checking PowerShell test script..." $Yellow
$psTestPath = "$PSScriptRoot\GYMBLE\test_payment_settings.ps1"

if (Test-Path $psTestPath) {
    $content = Get-Content $psTestPath -Raw
    
    # Check if the script is checking for port 8001
    if ($content -match '"http://localhost:8001/docs"') {
        Write-ColoredOutput "Found incorrect port (8001) in PowerShell test script" $Yellow
        
        # Replace with port 8000
        $newContent = $content -replace '"http://localhost:8001/docs"', '"http://localhost:8000/docs"'
        Set-Content -Path $psTestPath -Value $newContent
        
        Write-ColoredOutput "✓ Updated PowerShell test script to use port 8000" $Green
    } elseif ($content -match '"http://localhost:8000/docs"') {
        Write-ColoredOutput "✓ PowerShell test script already using correct port (8000)" $Green
    } else {
        Write-ColoredOutput "? Could not find port setting in PowerShell test script" $Yellow
    }
} else {
    Write-ColoredOutput "✗ Could not find PowerShell test script at $psTestPath" $Red
}

# Fix the Bash test script
Write-ColoredOutput "Checking Bash test script..." $Yellow
$shTestPath = "$PSScriptRoot\GYMBLE\test_payment_settings.sh"

if (Test-Path $shTestPath) {
    $content = Get-Content $shTestPath -Raw
    
    # Check if the script is checking for port 8001
    if ($content -match 'http://localhost:8001/docs') {
        Write-ColoredOutput "Found incorrect port (8001) in Bash test script" $Yellow
        
        # Replace with port 8000
        $newContent = $content -replace 'http://localhost:8001/docs', 'http://localhost:8000/docs'
        Set-Content -Path $shTestPath -Value $newContent
        
        Write-ColoredOutput "✓ Updated Bash test script to use port 8000" $Green
    } elseif ($content -match 'http://localhost:8000/docs') {
        Write-ColoredOutput "✓ Bash test script already using correct port (8000)" $Green
    } else {
        Write-ColoredOutput "? Could not find port setting in Bash test script" $Yellow
    }
} else {
    Write-ColoredOutput "✗ Could not find Bash test script at $shTestPath" $Red
}

# Summary
Write-Header "FIX SUMMARY"
Write-ColoredOutput "The test scripts have been updated to use port 8000 instead of 8001." $Green
Write-ColoredOutput "This matches the actual running port of your backend server." $Green
Write-ColoredOutput "\nAlternatively, you can start your server on port 8001 with:" $Yellow
Write-ColoredOutput "python -m uvicorn server:app --reload --port 8001" $Yellow

Write-Host "\nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")