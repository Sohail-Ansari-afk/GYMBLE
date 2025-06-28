import os
import re
import sys
import shutil

def fix_cors_configuration():
    """Fix the CORS configuration in server.py"""
    server_path = os.path.join("backend", "server.py")
    backup_path = os.path.join("backend", "server.py.bak")
    
    # Check if server.py exists
    if not os.path.exists(server_path):
        print(f"Error: {server_path} not found")
        return False
    
    # Create a backup
    shutil.copy2(server_path, backup_path)
    print(f"Created backup at {backup_path}")
    
    # Read the server.py file
    with open(server_path, 'r') as f:
        content = f.read()
    
    # Define the origins we want to ensure are in the ALLOWED_ORIGINS list
    required_origins = [
        '"http://localhost:52914"',  # Flutter web app port
        '"http://127.0.0.1:52914"',  # Alternative localhost
        '"http://localhost:*"',       # Any localhost port
        '"http://127.0.0.1:*"'        # Any 127.0.0.1 port
    ]
    
    # Find the ALLOWED_ORIGINS list
    allowed_origins_pattern = r'ALLOWED_ORIGINS\s*=\s*\[(.*?)\]'
    match = re.search(allowed_origins_pattern, content, re.DOTALL)
    
    if not match:
        print("Error: Could not find ALLOWED_ORIGINS list in server.py")
        return False
    
    # Extract the current origins
    current_origins = match.group(1).strip()
    
    # Check if each required origin is already in the list
    missing_origins = []
    for origin in required_origins:
        if origin not in current_origins:
            missing_origins.append(origin)
    
    if not missing_origins:
        print("All required origins are already in the ALLOWED_ORIGINS list")
        return True
    
    # Add the missing origins to the list
    new_origins = current_origins
    if current_origins and not current_origins.endswith(','):
        new_origins += ','
    
    for i, origin in enumerate(missing_origins):
        new_origins += f"\n    {origin}"
        if i < len(missing_origins) - 1 or not new_origins.endswith(','):
            new_origins += ','
    
    # Replace the old origins list with the new one
    new_content = re.sub(allowed_origins_pattern, f'ALLOWED_ORIGINS = [{new_origins}]', content, flags=re.DOTALL)
    
    # Write the updated content back to the file
    with open(server_path, 'w') as f:
        f.write(new_content)
    
    print("Updated ALLOWED_ORIGINS list in server.py")
    print("Added the following origins:")
    for origin in missing_origins:
        print(f"  - {origin}")
    
    print("\nPlease restart the backend server for changes to take effect")
    return True

def main():
    print("\n===== CORS Configuration Fix =====\n")
    print("This script will update the CORS configuration in server.py")
    print("to allow requests from the Flutter web app.\n")
    
    confirm = input("Do you want to proceed? (y/n): ")
    if confirm.lower() != 'y':
        print("Operation cancelled")
        return
    
    success = fix_cors_configuration()
    
    if success:
        print("\nCORS configuration updated successfully")
        print("\nNext steps:")
        print("1. Restart the backend server:")
        print("   cd backend && python -m uvicorn server:app --reload")
        print("2. Restart the Flutter web app")
        print("3. Test the connection again")
    else:
        print("\nFailed to update CORS configuration")
        print("Please check the server.py file manually")

if __name__ == "__main__":
    main()