import requests
import json
import sys
import os
from colorama import init, Fore, Style
from tabulate import tabulate

# Initialize colorama for colored terminal output
init(autoreset=True)

# Constants
BACKEND_URL = "http://localhost:8000"
API_BASE_URL = f"{BACKEND_URL}/api"
FLUTTER_ORIGIN = "http://localhost:52914"

# Test endpoints
ENDPOINTS = [
    "/gyms/all",
    "/",  # Root endpoint
    "/docs",  # Swagger docs (if available)
    "/openapi.json"  # OpenAPI schema (if available)
]

# Test origins
ORIGINS = [
    FLUTTER_ORIGIN,
    "http://localhost:3000",
    "http://127.0.0.1:52914",
    "http://127.0.0.1:8000",
    "null"  # Special case for file:// URLs
]

def print_header(text):
    """Print a formatted header"""
    print(f"\n{Fore.CYAN}{Style.BRIGHT}{'=' * 80}")
    print(f"{Fore.CYAN}{Style.BRIGHT}{text.center(80)}")
    print(f"{Fore.CYAN}{Style.BRIGHT}{'=' * 80}{Style.RESET_ALL}\n")

def print_section(text):
    """Print a section header"""
    print(f"\n{Fore.YELLOW}{Style.BRIGHT}{text}{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}{'-' * len(text)}{Style.RESET_ALL}\n")

def print_success(text):
    """Print a success message"""
    print(f"{Fore.GREEN}✓ {text}{Style.RESET_ALL}")

def print_error(text):
    """Print an error message"""
    print(f"{Fore.RED}✗ {text}{Style.RESET_ALL}")

def print_warning(text):
    """Print a warning message"""
    print(f"{Fore.YELLOW}! {text}{Style.RESET_ALL}")

def print_info(text):
    """Print an info message"""
    print(f"{Fore.BLUE}ℹ {text}{Style.RESET_ALL}")

def check_server_running():
    """Check if the backend server is running"""
    print_section("Checking if backend server is running")
    try:
        response = requests.get(BACKEND_URL, timeout=5)
        print_success(f"Backend server is running at {BACKEND_URL}")
        print_info(f"Status code: {response.status_code}")
        return True
    except requests.exceptions.ConnectionError:
        print_error(f"Cannot connect to backend server at {BACKEND_URL}")
        print_info("Make sure the server is running with: cd backend && python -m uvicorn server:app --reload")
        return False
    except Exception as e:
        print_error(f"Error checking server: {str(e)}")
        return False

def test_endpoint(endpoint, with_origin=None):
    """Test a specific API endpoint"""
    url = f"{API_BASE_URL}{endpoint}"
    headers = {}
    if with_origin:
        headers['Origin'] = with_origin
    
    try:
        response = requests.get(url, headers=headers, timeout=5)
        return {
            'status_code': response.status_code,
            'headers': dict(response.headers),
            'content': response.text[:200] + ('...' if len(response.text) > 200 else ''),
            'success': 200 <= response.status_code < 300
        }
    except Exception as e:
        return {
            'status_code': 0,
            'headers': {},
            'content': str(e),
            'success': False
        }

def test_options_request(endpoint, origin):
    """Test OPTIONS request (CORS preflight) for a specific endpoint and origin"""
    url = f"{API_BASE_URL}{endpoint}"
    headers = {
        'Origin': origin,
        'Access-Control-Request-Method': 'GET',
        'Access-Control-Request-Headers': 'Content-Type'
    }
    
    try:
        response = requests.options(url, headers=headers, timeout=5)
        cors_headers = {
            'Access-Control-Allow-Origin': response.headers.get('Access-Control-Allow-Origin'),
            'Access-Control-Allow-Methods': response.headers.get('Access-Control-Allow-Methods'),
            'Access-Control-Allow-Headers': response.headers.get('Access-Control-Allow-Headers'),
            'Access-Control-Allow-Credentials': response.headers.get('Access-Control-Allow-Credentials')
        }
        return {
            'status_code': response.status_code,
            'cors_headers': cors_headers,
            'all_headers': dict(response.headers),
            'success': 200 <= response.status_code < 300 and cors_headers['Access-Control-Allow-Origin'] is not None
        }
    except Exception as e:
        return {
            'status_code': 0,
            'cors_headers': {},
            'all_headers': {},
            'content': str(e),
            'success': False
        }

def test_all_endpoints():
    """Test all endpoints without any origin header"""
    print_section("Testing all endpoints (without Origin header)")
    
    results = []
    for endpoint in ENDPOINTS:
        result = test_endpoint(endpoint)
        status = f"{Fore.GREEN}✓" if result['success'] else f"{Fore.RED}✗"
        results.append([endpoint, result['status_code'], status])
        
        if result['success']:
            print_success(f"Endpoint {endpoint} returned status code {result['status_code']}")
        else:
            print_error(f"Endpoint {endpoint} failed with status code {result['status_code']}")
    
    print("\nEndpoint Test Results:")
    print(tabulate(results, headers=["Endpoint", "Status Code", "Success"], tablefmt="grid"))

def test_cors_for_flutter():
    """Test CORS configuration specifically for Flutter web app origin"""
    print_section(f"Testing CORS for Flutter web app origin: {FLUTTER_ORIGIN}")
    
    # Test regular GET request with Origin header
    endpoint = "/gyms/all"  # Use the endpoint that Flutter app is trying to access
    print_info(f"Testing GET request to {endpoint} with Origin: {FLUTTER_ORIGIN}")
    
    result = test_endpoint(endpoint, FLUTTER_ORIGIN)
    if result['success']:
        allow_origin = result['headers'].get('Access-Control-Allow-Origin')
        if allow_origin:
            if allow_origin == FLUTTER_ORIGIN or allow_origin == '*':
                print_success(f"Server allows GET requests from {FLUTTER_ORIGIN}")
                print_info(f"Access-Control-Allow-Origin: {allow_origin}")
            else:
                print_warning(f"Server allows requests but from a different origin: {allow_origin}")
        else:
            print_warning("Server responded successfully but without CORS headers")
    else:
        print_error(f"GET request failed with status code {result['status_code']}")
    
    # Test OPTIONS request (preflight)
    print_info(f"Testing OPTIONS request to {endpoint} (CORS preflight) with Origin: {FLUTTER_ORIGIN}")
    
    options_result = test_options_request(endpoint, FLUTTER_ORIGIN)
    if options_result['success']:
        allow_origin = options_result['cors_headers'].get('Access-Control-Allow-Origin')
        allow_methods = options_result['cors_headers'].get('Access-Control-Allow-Methods')
        allow_headers = options_result['cors_headers'].get('Access-Control-Allow-Headers')
        
        print_success(f"OPTIONS request succeeded with status code {options_result['status_code']}")
        print_info(f"Access-Control-Allow-Origin: {allow_origin}")
        print_info(f"Access-Control-Allow-Methods: {allow_methods}")
        print_info(f"Access-Control-Allow-Headers: {allow_headers}")
        
        if allow_origin != FLUTTER_ORIGIN and allow_origin != '*':
            print_warning(f"Server allows OPTIONS requests but from a different origin: {allow_origin}")
    else:
        print_error(f"OPTIONS request failed with status code {options_result['status_code']}")

def test_all_origins():
    """Test CORS configuration for all origins"""
    print_section("Testing CORS configuration for multiple origins")
    
    endpoint = "/gyms/all"  # Use the endpoint that Flutter app is trying to access
    results = []
    
    for origin in ORIGINS:
        options_result = test_options_request(endpoint, origin)
        allow_origin = options_result['cors_headers'].get('Access-Control-Allow-Origin')
        status = f"{Fore.GREEN}✓" if options_result['success'] else f"{Fore.RED}✗"
        results.append([origin, options_result['status_code'], allow_origin, status])
    
    print("\nCORS Test Results:")
    print(tabulate(results, headers=["Origin", "Status Code", "Allow-Origin", "Success"], tablefmt="grid"))

def analyze_server_py():
    """Analyze server.py to check CORS configuration"""
    print_section("Analyzing server.py CORS configuration")
    
    server_py_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backend", "server.py")
    if not os.path.exists(server_py_path):
        print_error(f"Cannot find server.py at {server_py_path}")
        return
    
    try:
        with open(server_py_path, 'r') as f:
            content = f.read()
        
        # Check for CORSMiddleware
        if "CORSMiddleware" in content:
            print_success("CORSMiddleware is configured in server.py")
            
            # Try to extract ALLOWED_ORIGINS
            import re
            origins_match = re.search(r'ALLOWED_ORIGINS\s*=\s*\[([^\]]+)\]', content)
            if origins_match:
                origins_str = origins_match.group(1)
                origins = [o.strip(' "\'\'') for o in origins_str.split(',')]
                print_info("Configured ALLOWED_ORIGINS:")
                for origin in origins:
                    if origin.strip():
                        if FLUTTER_ORIGIN in origin or '*' in origin:
                            print_success(f"  {origin}")
                        else:
                            print_info(f"  {origin}")
                
                if not any(FLUTTER_ORIGIN in origin or '*' in origin for origin in origins if origin.strip()):
                    print_warning(f"Flutter web app origin {FLUTTER_ORIGIN} is not in ALLOWED_ORIGINS")
                    print_info("You may need to add it to the ALLOWED_ORIGINS list in server.py")
            else:
                print_warning("Could not extract ALLOWED_ORIGINS from server.py")
        else:
            print_error("CORSMiddleware is not configured in server.py")
            print_info("You need to add CORSMiddleware to your FastAPI app")
    except Exception as e:
        print_error(f"Error analyzing server.py: {str(e)}")

def generate_recommendations():
    """Generate recommendations based on test results"""
    print_section("Recommendations")
    
    print(f"{Fore.CYAN}1. Update ALLOWED_ORIGINS in server.py:{Style.RESET_ALL}")
    print("   Make sure the following origins are included:")
    print(f"   - {FLUTTER_ORIGIN}")
    print(f"   - http://127.0.0.1:52914")
    print(f"   - http://localhost:*")
    print(f"   - http://127.0.0.1:*")
    print()
    
    print(f"{Fore.CYAN}2. Ensure CORSMiddleware is properly configured:{Style.RESET_ALL}")
    print("   app.add_middleware(")
    print("       CORSMiddleware,")
    print("       allow_origins=ALLOWED_ORIGINS,")
    print("       allow_credentials=True,")
    print("       allow_methods=["*"],")
    print("       allow_headers=["*"],")
    print("   )")
    print()
    
    print(f"{Fore.CYAN}3. After making changes:{Style.RESET_ALL}")
    print("   - Restart the backend server")
    print("   - Restart the Flutter web app")
    print("   - Run this test script again to verify the changes")
    print()
    
    print(f"{Fore.CYAN}4. For testing in browser:{Style.RESET_ALL}")
    print("   - Open cors_test.html in your browser")
    print("   - Use the browser's developer tools to inspect network requests")

def main():
    """Main function"""
    print_header("GYMBLE Backend API and CORS Test")
    
    # Check if required packages are installed
    try:
        import colorama
        import tabulate
    except ImportError:
        print("Installing required packages...")
        os.system(f"{sys.executable} -m pip install colorama tabulate")
    
    # Check if server is running
    if not check_server_running():
        print_error("Backend server is not running. Please start it before running this test.")
        return
    
    # Run tests
    test_all_endpoints()
    test_cors_for_flutter()
    test_all_origins()
    analyze_server_py()
    generate_recommendations()
    
    print_header("Test Completed")

if __name__ == "__main__":
    main()