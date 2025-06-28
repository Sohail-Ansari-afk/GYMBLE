#!/bin/bash

# Bash script to test the Payment Settings implementation

# Set colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

print_header() {
    echo ""
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 70))${NC}"
    echo -e "${BLUE}$(printf '%*s' $(((${#1}+70)/2)) "$1")${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 70))${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

test_command() {
    local command=$1
    local description=$2
    local working_dir=$3
    
    print_info "Running: $description"
    
    if [ -n "$working_dir" ]; then
        pushd "$working_dir" > /dev/null
    fi
    
    eval $command
    local status=$?
    
    if [ -n "$working_dir" ]; then
        popd > /dev/null
    fi
    
    if [ $status -eq 0 ]; then
        print_success "$description completed successfully"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

# Main script
print_header "PAYMENT SETTINGS IMPLEMENTATION TEST"

# Check if backend server is running
print_info "Checking if backend server is running..."
backend_running=false

if curl -s http://localhost:8000/docs -o /dev/null; then
    backend_running=true
    print_success "Backend server is running"
else
    print_error "Backend server is not running"
    print_info "Please start the backend server before running tests"
    exit 1
fi

# Check if frontend server is running
print_info "Checking if frontend server is running..."
frontend_running=false

if curl -s http://localhost:3000 -o /dev/null; then
    frontend_running=true
    print_success "Frontend server is running"
else
    print_error "Frontend server is not running"
    print_info "Please start the frontend server before running tests"
    exit 1
fi

# Run backend tests
print_header "BACKEND TESTS"
test_command "python test_payment_settings.py" "Backend API tests" "$(pwd)/GYMBLE/backend"
backend_test_success=$?

# Run frontend tests
print_header "FRONTEND TESTS"
test_command "npm test -- --testPathPattern=PaymentSettings.test.js" "Frontend component tests" "$(pwd)/GYMBLE/frontend"
frontend_test_success=$?

# Summary
print_header "TEST SUMMARY"

if [ $backend_test_success -eq 0 ]; then
    print_success "Backend tests: PASSED"
else
    print_error "Backend tests: FAILED"
fi

if [ $frontend_test_success -eq 0 ]; then
    print_success "Frontend tests: PASSED"
else
    print_error "Frontend tests: FAILED"
fi

echo ""
print_info "For more details, please refer to the PAYMENT_SETTINGS_TESTING.md file."
echo ""

# Open the testing guide
read -p "Would you like to open the testing guide? (y/n) " open_guide
if [ "$open_guide" = "y" ]; then
    if [ "$(uname)" == "Darwin" ]; then
        # macOS
        open "$(pwd)/GYMBLE/PAYMENT_SETTINGS_TESTING.md"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Linux
        xdg-open "$(pwd)/GYMBLE/PAYMENT_SETTINGS_TESTING.md"
    fi
fi

read -p "Press Enter to exit..."