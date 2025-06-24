from pymongo import MongoClient
from datetime import datetime, timedelta
import uuid
from enum import Enum
import bcrypt

# Define enums to match those in server.py
class PlanType(str, Enum):
    BASIC = "basic"
    PREMIUM = "premium"
    VIP = "vip"
    FAMILY = "family"

class MembershipStatus(str, Enum):
    ACTIVE = "active"
    EXPIRED = "expired"
    SUSPENDED = "suspended"
    PENDING = "pending"

class UserRole(str, Enum):
    OWNER = "owner"
    STAFF = "staff"
    MEMBER = "member"

class PaymentMethod(str, Enum):
    CASH = "cash"
    CARD = "card"
    UPI = "upi"
    BANK_TRANSFER = "bank_transfer"

# Connect to MongoDB - use GYMBLE instead of gymble (case sensitive)
client = MongoClient('mongodb://localhost:27017')
db = client.GYMBLE

# Helper function to hash passwords
def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

# Create a gym if none exists
gym_id = str(uuid.uuid4())
existing_gym = db.gyms.find_one({})
if existing_gym:
    gym_id = existing_gym["id"]
    print(f"Using existing gym with ID: {gym_id}")
else:
    gym = {
        "id": gym_id,
        "name": "Sample Gym",
        "address": "123 Fitness Street",
        "phone": "+91 9876543210",
        "email": "sample@gym.com",
        "created_at": datetime.utcnow(),
        "is_active": True
    }
    db.gyms.insert_one(gym)
    print(f"Created new gym with ID: {gym_id}")

# Create a gym owner if none exists
owner_email = "owner@gym.com"
existing_owner = db.users.find_one({"email": owner_email})
if existing_owner:
    print(f"Using existing gym owner: {owner_email}")
else:
    owner = {
        "id": str(uuid.uuid4()),
        "email": owner_email,
        "password_hash": hash_password("password123"),
        "name": "Gym Owner",
        "phone": "+91 9876543210",
        "role": UserRole.OWNER,
        "gym_id": gym_id,
        "created_at": datetime.utcnow()
    }
    db.users.insert_one(owner)
    print(f"Created new gym owner: {owner_email}")

# Create a plan if none exists
plan_id = str(uuid.uuid4())
existing_plan = db.plans.find_one({"gym_id": gym_id})
if existing_plan:
    plan_id = existing_plan["id"]
    print(f"Using existing plan with ID: {plan_id}")
else:
    plan = {
        "id": plan_id,
        "gym_id": gym_id,
        "name": "Basic Plan",
        "description": "Basic membership with access to all equipment",
        "price": 1500,
        "duration_days": 30,
        "plan_type": PlanType.BASIC,
        "features": ["Access to gym equipment", "Locker access"],
        "auto_renewal": True,
        "created_at": datetime.utcnow(),
        "is_active": True
    }
    db.plans.insert_one(plan)
    print(f"Created new plan with ID: {plan_id}")

# Create a member if none exists
member_email = "member@example.com"
existing_member = db.members.find_one({"email": member_email})
if existing_member:
    print(f"Using existing member: {member_email}")
else:
    # Create user account for member
    password_hash = hash_password("password123")
    user = {
        "id": str(uuid.uuid4()),
        "email": member_email,
        "password_hash": password_hash,
        "name": "John Member",
        "phone": "+91 9876543211",
        "role": UserRole.MEMBER,
        "gym_id": gym_id,
        "created_at": datetime.utcnow()
    }
    db.users.insert_one(user)
    
    # Create member profile
    member_id = str(uuid.uuid4())
    start_date = datetime.utcnow()
    end_date = start_date + timedelta(days=30)
    
    member = {
        "id": member_id,
        "gym_id": gym_id,
        "name": "John Member",
        "email": member_email,
        "password_hash": password_hash,
        "phone": "+91 9876543211",
        "address": "456 Fitness Avenue",
        "date_of_birth": "1990-01-01",
        "emergency_contact": "+91 9876543212",
        "plan_id": plan_id,
        "membership_status": MembershipStatus.ACTIVE,
        "start_date": start_date,
        "end_date": end_date,
        "created_at": datetime.utcnow(),
        "total_visits": 0,
        "auto_renewal": True
    }
    db.members.insert_one(member)
    
    # Create payment record
    payment = {
        "id": str(uuid.uuid4()),
        "gym_id": gym_id,
        "member_id": member_id,
        "member_name": "John Member",
        "amount": 1500,
        "payment_method": PaymentMethod.CASH,
        "plan_id": plan_id,
        "plan_name": "Basic Plan",
        "payment_date": datetime.utcnow(),
        "payment_status": "completed"
    }
    db.payments.insert_one(payment)
    
    print(f"Created new member: {member_email}")

print("\nSample data creation complete!")
print("\nLogin credentials:")
print(f"Gym Owner: {owner_email} / password123")
print(f"Member: {member_email} / password123")