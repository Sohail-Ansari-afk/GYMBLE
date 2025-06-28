import requests
import json
import os
import sys
import re
import platform
import subprocess
from datetime import datetime

# Try to import colorama for colored output
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
    COLORS_ENABLED = True
except ImportError:
    # Define dummy color constants if colorama is not available
    class DummyFore:
        def __getattr__(self, name):
            return ''
    class DummyStyle:
        def __getattr__(self, name):
            return ''
    Fore = DummyFore()
    Style = DummyStyle()
    COLORS_ENABLED = False

# Constants
BACKEND_URL = "http://localhost:8000"
API_BASE_URL = f"{BACKEND_URL}/api"
FLUTTER_ORIGIN = "http://localhost:52914"
LOG_FILE = "cors_diagnostic_log.txt"

# Initialize log file
def init_log_file():
    with open(LOG_FILE, "w") as f:
        f.write(f"GYMBLE CORS Diagnostic Tool Log - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("=" * 80 + "\n\n")

# Log function
def log(message, level="INFO"):
    with open(LOG_FILE, "a") as f:
        f.write(f"[{level}] {message}\n")

# Print functions with color
def print_header(text):
    print(f"\n{Fore.CYAN}{Style.BRIGHT}{'=' * 80}")
    print(f"{Fore.CYAN}{Style.BRIGHT}{text.center(80)}")
    print(f"{Fore.CYAN}{Style.BRIGHT}{'=' * 80}{Style.RESET_ALL}\n")
    log(f"{'=' * 40} {text} {'=' * 40}", "HEADER")

def print_section(text):
    print(f"\n{Fore.YELLOW}{Style.BRIGHT}{text}{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}{'-' * len(text)}{Style.RESET_ALL}\n")
    log(f"\n--- {text} ---", "SECTION")

def print_success(text):
    print(f"{Fore.GREEN}✓ {text}{Style.RESET_ALL}")
    log(f"SUCCESS: {text}")

def print_error(text):
    print(f"{Fore.RED}✗ {text}{Style.RESET_ALL}")
    log(f"ERROR: {text}", "ERROR")

def print_warning(text):
    print(f"{Fore.YELLOW}! {text}{Style.RESET_ALL}")
    log(f"WARNING: {text}", "WARNING")

def print_info(text):
    print(f"{Fore.BLUE}ℹ {text}{Style.RESET_ALL}")
    log(f"INFO: {text}")

# Check if required packages are installed
def check_dependencies():
    required_packages = ["requests", "colorama"]
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print_warning(f"Missing required packages: {', '.join(missing_packages)}")
        install = input("Do you want to install them now? (y/n): ").lower()
        if install == 'y':
            for package in missing_packages:
                print_info(f"Installing {package}...")
                subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            print_success("All required packages installed.")
            # Reinitialize colorama if it was just installed
            if "colorama" in missing_packages:
                from colorama import init, Fore, Style
                init(autoreset=True)
                global COLORS_ENABLED
                COLORS_ENABLED = True
        else:
            print_warning("Continuing without required packages. Some features may not work.")

# Check if backend server is running
def check_server_running():
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

# Test a specific API endpoint
def test_endpoint(endpoint, with_origin=None):
    url = f"{API_BASE_URL}{endpoint}"
    headers = {}
    if with_origin:
        headers['Origin'] = with_origin
    
    try:
        print_info(f"Testing GET request to {url}" + (f" with Origin: {with_origin}" if with_origin else ""))
        response = requests.get(url, headers=headers, timeout=5)
        
        if 200 <= response.status_code < 300:
            print_success(f"Endpoint {endpoint} returned status code {response.status_code}")
        else:
            print_error(f"Endpoint {endpoint} failed with status code {response.status_code}")
        
        # Check CORS headers if origin was provided
        if with_origin:
            allow_origin = response.headers.get('Access-Control-Allow-Origin')
            if allow_origin:
                if allow_origin == with_origin or allow_origin == '*':
                    print_success(f"Server allows requests from {with_origin}")
                else:
                    print_warning(f"Server allows requests but from a different origin: {allow_origin}")
            else:
                print_warning("Server responded without CORS headers")
        
        return {
            'status_code': response.status_code,
            'headers': dict(response.headers),
            'content': response.text[:200] + ('...' if len(response.text) > 200 else ''),
            'success': 200 <= response.status_code < 300
        }
    except Exception as e:
        print_error(f"Error testing endpoint {endpoint}: {str(e)}")
        return {
            'status_code': 0,
            'headers': {},
            'content': str(e),
            'success': False
        }

# Test OPTIONS request (CORS preflight)
def test_options_request(endpoint, origin):
    url = f"{API_BASE_URL}{endpoint}"
    headers = {
        'Origin': origin,
        'Access-Control-Request-Method': 'GET',
        'Access-Control-Request-Headers': 'Content-Type'
    }
    
    try:
        print_info(f"Testing OPTIONS request to {url} with Origin: {origin}")
        response = requests.options(url, headers=headers, timeout=5)
        
        cors_headers = {
            'Access-Control-Allow-Origin': response.headers.get('Access-Control-Allow-Origin'),
            'Access-Control-Allow-Methods': response.headers.get('Access-Control-Allow-Methods'),
            'Access-Control-Allow-Headers': response.headers.get('Access-Control-Allow-Headers'),
            'Access-Control-Allow-Credentials': response.headers.get('Access-Control-Allow-Credentials')
        }
        
        if 200 <= response.status_code < 300 and cors_headers['Access-Control-Allow-Origin']:
            print_success(f"OPTIONS request succeeded with status code {response.status_code}")
            print_info(f"Access-Control-Allow-Origin: {cors_headers['Access-Control-Allow-Origin']}")
            print_info(f"Access-Control-Allow-Methods: {cors_headers['Access-Control-Allow-Methods']}")
            print_info(f"Access-Control-Allow-Headers: {cors_headers['Access-Control-Allow-Headers']}")
            
            if cors_headers['Access-Control-Allow-Origin'] != origin and cors_headers['Access-Control-Allow-Origin'] != '*':
                print_warning(f"Server allows OPTIONS requests but from a different origin: {cors_headers['Access-Control-Allow-Origin']}")
        else:
            print_error(f"OPTIONS request failed with status code {response.status_code}")
            if response.status_code == 200 and not cors_headers['Access-Control-Allow-Origin']:
                print_warning("Server responded with 200 OK but without CORS headers")
        
        return {
            'status_code': response.status_code,
            'cors_headers': cors_headers,
            'all_headers': dict(response.headers),
            'success': 200 <= response.status_code < 300 and cors_headers['Access-Control-Allow-Origin'] is not None
        }
    except Exception as e:
        print_error(f"Error testing OPTIONS request: {str(e)}")
        return {
            'status_code': 0,
            'cors_headers': {},
            'all_headers': {},
            'content': str(e),
            'success': False
        }

# Analyze server.py to check CORS configuration
def analyze_server_py():
    print_section("Analyzing server.py CORS configuration")
    
    server_py_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backend", "server.py")
    if not os.path.exists(server_py_path):
        print_error(f"Cannot find server.py at {server_py_path}")
        return None
    
    try:
        with open(server_py_path, 'r') as f:
            content = f.read()
        
        # Check for CORSMiddleware
        if "CORSMiddleware" in content:
            print_success("CORSMiddleware is configured in server.py")
            
            # Try to extract ALLOWED_ORIGINS
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
                
                return {
                    'has_cors_middleware': True,
                    'allowed_origins': origins,
                    'flutter_origin_allowed': any(FLUTTER_ORIGIN in origin or '*' in origin for origin in origins if origin.strip()),
                    'content': content
                }
            else:
                print_warning("Could not extract ALLOWED_ORIGINS from server.py")
                return {
                    'has_cors_middleware': True,
                    'allowed_origins': [],
                    'flutter_origin_allowed': False,
                    'content': content
                }
        else:
            print_error("CORSMiddleware is not configured in server.py")
            print_info("You need to add CORSMiddleware to your FastAPI app")
            return {
                'has_cors_middleware': False,
                'allowed_origins': [],
                'flutter_origin_allowed': False,
                'content': content
            }
    except Exception as e:
        print_error(f"Error analyzing server.py: {str(e)}")
        return None

# Fix CORS configuration in server.py
def fix_cors_configuration(server_py_analysis):
    if not server_py_analysis:
        print_error("Cannot fix CORS configuration without server.py analysis")
        return False
    
    print_section("Fixing CORS configuration in server.py")
    
    server_py_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backend", "server.py")
    content = server_py_analysis['content']
    
    # Create backup of server.py
    backup_path = f"{server_py_path}.bak"
    try:
        with open(backup_path, 'w') as f:
            f.write(content)
        print_success(f"Created backup of server.py at {backup_path}")
    except Exception as e:
        print_error(f"Error creating backup: {str(e)}")
        return False
    
    # Fix CORS configuration
    if server_py_analysis['has_cors_middleware']:
        # Update ALLOWED_ORIGINS
        origins_to_add = [
            FLUTTER_ORIGIN,
            "http://127.0.0.1:52914",
            "http://localhost:*",
            "http://127.0.0.1:*"
        ]
        
        current_origins = server_py_analysis['allowed_origins']
        new_origins = current_origins.copy()
        
        for origin in origins_to_add:
            if not any(origin in o for o in current_origins):
                new_origins.append(origin)
        
        # Format the new origins list
        formatted_origins = ", ".join([f'"{o}"' for o in new_origins if o.strip()])
        new_origins_str = f"ALLOWED_ORIGINS = [{formatted_origins}]"
        
        # Replace the old origins list
        origins_pattern = r'ALLOWED_ORIGINS\s*=\s*\[[^\]]+\]'
        if re.search(origins_pattern, content):
            new_content = re.sub(origins_pattern, new_origins_str, content)
            
            try:
                with open(server_py_path, 'w') as f:
                    f.write(new_content)
                print_success("Updated ALLOWED_ORIGINS in server.py")
                print_info("New ALLOWED_ORIGINS:")
                for origin in new_origins:
                    if origin.strip():
                        print_info(f"  {origin}")
                return True
            except Exception as e:
                print_error(f"Error writing to server.py: {str(e)}")
                return False
        else:
            print_error("Could not find ALLOWED_ORIGINS pattern in server.py")
            return False
    else:
        # Add CORSMiddleware configuration
        cors_middleware_code = '''
# CORS configuration
from fastapi.middleware.cors import CORSMiddleware

ALLOWED_ORIGINS = ["http://localhost:52914", "http://127.0.0.1:52914", "http://localhost:*", "http://127.0.0.1:*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
'''
        
        # Find a good place to insert the CORS middleware code
        # Look for the FastAPI app initialization
        app_pattern = r'app\s*=\s*FastAPI\(.*?\)'
        app_match = re.search(app_pattern, content)
        
        if app_match:
            # Insert after the app initialization
            insert_pos = app_match.end()
            new_content = content[:insert_pos] + cors_middleware_code + content[insert_pos:]
            
            try:
                with open(server_py_path, 'w') as f:
                    f.write(new_content)
                print_success("Added CORSMiddleware configuration to server.py")
                return True
            except Exception as e:
                print_error(f"Error writing to server.py: {str(e)}")
                return False
        else:
            print_error("Could not find FastAPI app initialization in server.py")
            return False

# Generate recommendations
def generate_recommendations(server_py_analysis):
    print_section("Recommendations")
    
    if server_py_analysis:
        if not server_py_analysis['has_cors_middleware']:
            print_info("1. Add CORSMiddleware to your FastAPI app:")
            print("""```python
# CORS configuration
from fastapi.middleware.cors import CORSMiddleware

ALLOWED_ORIGINS = ["http://localhost:52914", "http://127.0.0.1:52914", "http://localhost:*", "http://127.0.0.1:*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```""")
        elif not server_py_analysis['flutter_origin_allowed']:
            print_info("1. Update ALLOWED_ORIGINS in server.py to include:")
            print(f"   - {FLUTTER_ORIGIN}")
            print(f"   - http://127.0.0.1:52914")
            print(f"   - http://localhost:*")
            print(f"   - http://127.0.0.1:*")
        else:
            print_info("1. Your CORS configuration looks good!")
    else:
        print_info("1. Check your server.py file and add proper CORS configuration")
    
    print_info("\n2. After making changes:")
    print("   - Restart the backend server")
    print("   - Restart the Flutter web app")
    print("   - Run this diagnostic tool again to verify the changes")
    
    print_info("\n3. For testing in browser:")
    print("   - Open cors_test.html in your browser")
    print("   - Use the browser's developer tools to inspect network requests")
    
    print_info("\n4. Additional resources:")
    print("   - FastAPI CORS documentation: https://fastapi.tiangolo.com/tutorial/cors/")
    print("   - MDN CORS guide: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS")

# Main function
def main():
    print_header("GYMBLE CORS Diagnostic Tool")
    init_log_file()
    
    # Check dependencies
    check_dependencies()
    
    # Check if server is running
    if not check_server_running():
        print_error("Backend server is not running. Please start it before running this diagnostic tool.")
        return
    
    # Test endpoints
    print_section("Testing API endpoints")
    test_endpoint("/gyms/all")
    test_endpoint("/gyms/all", FLUTTER_ORIGIN)
    
    # Test OPTIONS requests
    print_section("Testing CORS preflight requests")
    test_options_request("/gyms/all", FLUTTER_ORIGIN)
    
    # Analyze server.py
    server_py_analysis = analyze_server_py()
    
    # Ask if user wants to fix CORS configuration
    if server_py_analysis and (not server_py_analysis['has_cors_middleware'] or not server_py_analysis['flutter_origin_allowed']):
        fix = input("\nDo you want to automatically fix the CORS configuration? (y/n): ").lower()
        if fix == 'y':
            if fix_cors_configuration(server_py_analysis):
                print_success("CORS configuration fixed successfully!")
                print_info("Please restart your backend server for the changes to take effect.")
            else:
                print_error("Failed to fix CORS configuration.")
                generate_recommendations(server_py_analysis)
        else:
            generate_recommendations(server_py_analysis)
    else:
        generate_recommendations(server_py_analysis)
    
    print_header("Diagnostic Completed")
    print_info(f"A detailed log has been saved to {LOG_FILE}")

if __name__ == "__main__":
    main()