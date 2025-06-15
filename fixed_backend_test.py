#!/usr/bin/env python3
"""
Fixed GYMBLE API Test Script

This script properly tests the gym management system by addressing the authorization issues
found in the original testing. The main fix is ensuring proper role-based access:
- QR code generation requires owner/staff authentication
- Attendance marking requires member authentication

The 403 error was not a bug but correct security behavior.
"""

import requests
import sys
import time
from datetime import datetime
import json

# Backend URL - using environment variable
BACKEND_URL = "https://61249caf-5cdd-4f50-a725-bd21216c146d.preview.emergentagent.com"
API = f"{BACKEND_URL}/api"

class FixedGymbleAPITester:
    def __init__(self, base_url=API):
        self.base_url = base_url
        self.owner_token = None
        self.member_token = None
        self.tests_run = 0
        self.tests_passed = 0
        self.gym_id = None
        self.plan_id = None
        self.member_id = None
        self.qr_code_data = None
        self.numeric_code = None
        self.owner_credentials = None
        self.member_credentials = None

    def log_test(self, name, success, details=""):
        """Log test results with enhanced output"""
        self.tests_run += 1
        if success:
            self.tests_passed += 1
            print(f"✅ {name}: PASSED")
        else:
            print(f"❌ {name}: FAILED - {details}")
        
        if details and success:
            print(f"   📋 {details}")

    def run_api_call(self, method, endpoint, expected_status, data=None, params=None, token=None):
        """Enhanced API call handler with better error reporting"""
        url = f"{self.base_url}/{endpoint}"
        headers = {'Content-Type': 'application/json'}
        
        if token:
            headers['Authorization'] = f'Bearer {token}'

        try:
            if method == 'GET':
                response = requests.get(url, headers=headers, params=params)
            elif method == 'POST':
                response = requests.post(url, json=data, headers=headers, params=params)
            elif method == 'PUT':
                response = requests.put(url, json=data, headers=headers, params=params)
            elif method == 'DELETE':
                response = requests.delete(url, headers=headers)

            success = response.status_code == expected_status
            
            if success:
                try:
                    return True, response.json()
                except:
                    return True, {}
            else:
                try:
                    error_detail = response.json().get('detail', 'No detail provided')
                except:
                    error_detail = f"HTTP {response.status_code}: {response.text[:200]}"
                return False, {"error": error_detail, "status_code": response.status_code}

        except Exception as e:
            return False, {"error": str(e)}

    def test_system_health(self):
        """Test basic system health and connectivity"""
        print("\n🔍 Phase 1: System Health & Connectivity")
        
        # Health check
        success, data = self.run_api_call("GET", "health", 200)
        self.log_test("Backend Health Check", success, 
                     f"Service: {data.get('service', 'Unknown')}" if success else data.get('error'))
        
        if not success:
            return False
        
        # Root endpoint
        success, data = self.run_api_call("GET", "", 200)
        self.log_test("API Root Endpoint", success, 
                     f"Message: {data.get('message', 'Unknown')}" if success else data.get('error'))
        
        return success

    def test_gym_and_plan_setup(self):
        """Test or create gym and plan setup"""
        print("\n🔍 Phase 2: Gym & Plan Infrastructure")
        
        # Get all gyms
        success, gyms_data = self.run_api_call("GET", "gyms/all", 200)
        self.log_test("Get All Gyms", success, 
                     f"Found {len(gyms_data)} gyms" if success else gyms_data.get('error'))
        
        if not success:
            return False
        
        # Check for existing Test Gym
        test_gym = next((gym for gym in gyms_data if gym['name'] == 'Test Gym'), None)
        
        if test_gym:
            print(f"   🏢 Found existing Test Gym: {test_gym['id']}")
            self.gym_id = test_gym['id']
            
            # Get plans for existing gym
            success, plans_data = self.run_api_call("GET", f"plans/gym/{self.gym_id}", 200)
            self.log_test("Get Gym Plans", success, 
                         f"Found {len(plans_data)} plans" if success else plans_data.get('error'))
            
            if success:
                basic_plan = next((plan for plan in plans_data if plan['name'] == 'Basic Plan'), None)
                if basic_plan:
                    self.plan_id = basic_plan['id']
                    print(f"   📋 Found existing Basic Plan: {basic_plan['id']}")
                    return True
        
        # Need to create gym and plan - register owner first
        return self.create_gym_infrastructure()

    def create_gym_infrastructure(self):
        """Create new gym infrastructure with owner"""
        print("\n🔧 Creating New Gym Infrastructure")
        
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        
        # Register gym owner
        owner_data = {
            "email": f"owner_{timestamp}@testgym.com",
            "password": "Password123",
            "name": "Test Gym Owner",
            "phone": "+919876543210",
            "role": "owner"
        }
        
        success, response = self.run_api_call("POST", "auth/register", 200, owner_data)
        self.log_test("Owner Registration", success, 
                     f"Registered: {owner_data['email']}" if success else response.get('error'))
        
        if not success:
            return False
        
        self.owner_token = response['access_token']
        self.owner_credentials = {"email": owner_data['email'], "password": owner_data['password']}
        
        # Create gym
        gym_data = {
            "name": "Test Gym",
            "address": "123 Test Street, Test City",
            "phone": "+919876543210",
            "email": f"gym_{timestamp}@testgym.com",
            "description": "A test gym for API validation"
        }
        
        success, response = self.run_api_call("POST", "gyms", 200, gym_data, token=self.owner_token)
        self.log_test("Gym Creation", success, 
                     f"Created: {gym_data['name']}" if success else response.get('error'))
        
        if not success:
            return False
        
        self.gym_id = response['id']
        
        # Create membership plan
        plan_data = {
            "name": "Basic Plan",
            "description": "A basic membership plan for testing",
            "price": 1000.0,
            "duration_days": 30,
            "plan_type": "basic",
            "features": ["Access to gym equipment", "Locker access", "Basic support"]
        }
        
        success, response = self.run_api_call("POST", "plans", 200, plan_data, token=self.owner_token)
        self.log_test("Plan Creation", success, 
                     f"Created: {plan_data['name']}" if success else response.get('error'))
        
        if not success:
            return False
        
        self.plan_id = response['id']
        return True

    def test_member_registration_and_auth(self):
        """Test member registration and authentication"""
        print("\n🔍 Phase 3: Member Registration & Authentication")
        
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        
        # Register member
        member_data = {
            "email": f"member_{timestamp}@testgym.com",
            "password": "Password123",
            "name": "Test Member",
            "phone": "+919876543211",
            "gym_id": self.gym_id,
            "plan_id": self.plan_id
        }
        
        success, response = self.run_api_call("POST", "auth/register-member", 200, member_data)
        self.log_test("Member Registration", success, 
                     f"Registered: {member_data['email']}" if success else response.get('error'))
        
        if not success:
            return False
        
        self.member_token = response['access_token']
        self.member_credentials = {"email": member_data['email'], "password": member_data['password']}
        
        # Test member login
        login_data = {"email": member_data['email'], "password": member_data['password']}
        success, response = self.run_api_call("POST", "auth/login", 200, login_data)
        self.log_test("Member Login", success, 
                     f"Logged in: {login_data['email']}" if success else response.get('error'))
        
        if not success:
            return False
        
        # Verify token is valid
        self.member_token = response['access_token']
        
        # Get member profile
        success, response = self.run_api_call("GET", "members/me", 200, token=self.member_token)
        self.log_test("Member Profile Retrieval", success, 
                     f"Profile for: {response.get('name', 'Unknown')}" if success else response.get('error'))
        
        if success:
            self.member_id = response['id']
        
        return success

    def test_role_based_qr_generation(self):
        """Test QR code generation with proper role-based access"""
        print("\n🔍 Phase 4: QR Code Generation (Authorization Testing)")
        
        # First, test that member CANNOT generate QR codes (this should fail with 403)
        success, response = self.run_api_call("GET", "attendance/qr-code", 403, token=self.member_token)
        self.log_test("Member QR Access Denial", success, 
                     "Correctly denied - members cannot generate QR codes" if success 
                     else f"Unexpected result: {response.get('error')}")
        
        # Now test that owner CAN generate QR codes
        if not self.owner_token:
            # Need to login as owner
            if self.owner_credentials:
                success, response = self.run_api_call("POST", "auth/login", 200, self.owner_credentials)
                if success:
                    self.owner_token = response['access_token']
        
        if not self.owner_token:
            self.log_test("Owner Authentication", False, "No owner token available")
            return False
        
        success, response = self.run_api_call("GET", "attendance/qr-code", 200, token=self.owner_token)
        self.log_test("Owner QR Code Generation", success, 
                     f"Generated QR with numeric code: {response.get('numeric_code', 'Unknown')}" 
                     if success else response.get('error'))
        
        if success:
            self.qr_code_data = response.get('qr_code_data')
            self.numeric_code = response.get('numeric_code')
            print(f"   🔢 Numeric Code: {self.numeric_code}")
            print(f"   ⏰ Expires: {response.get('expires_at', 'Unknown')}")
        
        return success

    def test_member_attendance_marking(self):
        """Test attendance marking by member using QR/numeric code"""
        print("\n🔍 Phase 5: Member Attendance Marking")
        
        if not self.numeric_code:
            self.log_test("Attendance Prerequisites", False, "No numeric code available")
            return False
        
        # Check member's initial attendance status
        success, response = self.run_api_call("GET", "attendance/my-status", 200, token=self.member_token)
        self.log_test("Initial Attendance Status", success, 
                     f"Status: {response.get('status', 'Unknown')}" if success else response.get('error'))
        
        # Mark attendance using numeric code
        attendance_data = {
            "numeric_code": self.numeric_code,
            "device_info": "Test Device - Fixed API Test"
        }
        
        success, response = self.run_api_call("POST", "attendance/mark", 200, attendance_data, token=self.member_token)
        self.log_test("Attendance Check-in", success, 
                     f"Action: Check-in completed" if success else response.get('error'))
        
        if not success:
            return False
        
        # Verify attendance status after check-in
        success, response = self.run_api_call("GET", "attendance/my-status", 200, token=self.member_token)
        self.log_test("Post Check-in Status", success, 
                     f"Status: {response.get('status', 'Unknown')}" if success else response.get('error'))
        
        if success and response.get('status') == 'checked_in':
            print("   ✅ Member successfully checked in!")
            
            # Test check-out (marking attendance again should check out)
            success, response = self.run_api_call("POST", "attendance/mark", 200, attendance_data, token=self.member_token)
            self.log_test("Attendance Check-out", success, 
                         f"Action: Check-out completed" if success else response.get('error'))
        
        return success

    def test_dashboard_and_analytics(self):
        """Test dashboard stats and real-time updates"""
        print("\n🔍 Phase 6: Dashboard & Analytics")
        
        # Test owner dashboard stats
        success, response = self.run_api_call("GET", "dashboard/stats", 200, token=self.owner_token)
        self.log_test("Dashboard Stats", success, 
                     f"Members: {response.get('total_members', 0)}, Today's check-ins: {response.get('today_checkins', 0)}" 
                     if success else response.get('error'))
        
        # Test live attendance updates
        success, response = self.run_api_call("GET", "attendance/live-updates", 200, token=self.owner_token)
        self.log_test("Live Attendance Updates", success, 
                     f"Currently in gym: {response.get('stats', {}).get('currently_in', 0)}" 
                     if success else response.get('error'))
        
        # Test member stats
        success, response = self.run_api_call("GET", "members/me/stats", 200, token=self.member_token)
        self.log_test("Member Personal Stats", success, 
                     f"Total visits: {response.get('total_visits', 0)}, Days remaining: {response.get('days_remaining', 0)}" 
                     if success else response.get('error'))
        
        return True

    def test_calendar_integration(self):
        """Test calendar functionality"""
        print("\n🔍 Phase 7: Calendar Integration")
        
        current_date = datetime.now()
        year = current_date.year
        month = current_date.month
        
        success, response = self.run_api_call("GET", f"attendance/calendar/{year}/{month}", 200, token=self.owner_token)
        self.log_test("Attendance Calendar", success, 
                     f"Calendar for {response.get('month_name', 'Unknown')} {year}" 
                     if success else response.get('error'))
        
        if success:
            days_with_attendance = sum(1 for day in response.get('days', []) if day.get('total_attendance', 0) > 0)
            print(f"   📅 Days with attendance this month: {days_with_attendance}")
        
        return success

    def run_comprehensive_test(self):
        """Run the complete test suite with proper authorization handling"""
        print("🚀 GYMBLE API - Fixed Authorization Test Suite")
        print("=" * 70)
        print("🔧 Fixes Applied:")
        print("   • Proper role separation: Owner generates QR, Member scans QR")
        print("   • Correct 403 handling: Members cannot generate QR codes")
        print("   • Enhanced error reporting and test validation")
        print("=" * 70)
        
        # Run test phases
        test_phases = [
            ("System Health", self.test_system_health),
            ("Gym Infrastructure", self.test_gym_and_plan_setup),
            ("Member Authentication", self.test_member_registration_and_auth),
            ("Role-Based QR Generation", self.test_role_based_qr_generation),
            ("Attendance Marking", self.test_member_attendance_marking),
            ("Dashboard & Analytics", self.test_dashboard_and_analytics),
            ("Calendar Integration", self.test_calendar_integration),
        ]
        
        failed_phases = []
        
        for phase_name, test_function in test_phases:
            try:
                result = test_function()
                if not result:
                    failed_phases.append(phase_name)
                    print(f"⚠️  Phase '{phase_name}' had failures but continuing...")
            except Exception as e:
                failed_phases.append(phase_name)
                print(f"💥 Phase '{phase_name}' crashed: {str(e)}")
        
        # Final Results
        print("\n" + "=" * 70)
        print("📊 FINAL TEST RESULTS")
        print("=" * 70)
        print(f"Total Tests Run: {self.tests_run}")
        print(f"Tests Passed: {self.tests_passed}")
        print(f"Tests Failed: {self.tests_run - self.tests_passed}")
        print(f"Success Rate: {(self.tests_passed / self.tests_run) * 100:.1f}%")
        
        if failed_phases:
            print(f"\n⚠️  Phases with issues: {', '.join(failed_phases)}")
        
        if self.tests_passed == self.tests_run:
            print("\n🎉 ALL TESTS PASSED! The authorization issues have been resolved.")
            print("✅ Key Fixes Verified:")
            print("   • QR code generation properly restricted to owners/staff")
            print("   • Members can successfully mark attendance using QR codes")
            print("   • Role-based access control working correctly")
            print("   • End-to-end attendance workflow functional")
        else:
            print(f"\n⚠️  {self.tests_run - self.tests_passed} tests still failing")
        
        print("\n" + "=" * 70)
        
        return self.tests_passed == self.tests_run


if __name__ == "__main__":
    print("🔧 Fixed GYMBLE API Tester - Addressing Authorization Issues")
    print("This version properly handles role-based access control\n")
    
    tester = FixedGymbleAPITester()
    success = tester.run_comprehensive_test()
    
    sys.exit(0 if success else 1)