from pymongo import MongoClient
from enum import Enum

# Define PlanType enum to match the one in server.py
class PlanType(str, Enum):
    BASIC = "basic"
    PREMIUM = "premium"
    VIP = "vip"
    FAMILY = "family"

# Connect to MongoDB - use GYMBLE instead of gymble (case sensitive)
client = MongoClient('mongodb://localhost:27017')
db = client.GYMBLE

# Count plans before update
plans_count = db.plans.count_documents({})
plans_without_type = db.plans.count_documents({"plan_type": {"$exists": False}})

print(f"Total plans: {plans_count}")
print(f"Plans without plan_type: {plans_without_type}")

# Update plans without plan_type
if plans_without_type > 0:
    # Default to BASIC plan type
    result = db.plans.update_many(
        {"plan_type": {"$exists": False}},
        {"$set": {"plan_type": PlanType.BASIC}}
    )
    print(f"Updated {result.modified_count} plans with plan_type=basic")

# Count members before update
members_count = db.members.count_documents({})
members_without_plan_id = db.members.count_documents({"plan_id": {"$exists": False}})
members_without_end_date = db.members.count_documents({"end_date": {"$exists": False}})

print(f"\nTotal members: {members_count}")
print(f"Members without plan_id: {members_without_plan_id}")
print(f"Members without end_date: {members_without_end_date}")

# Update members without end_date
if members_without_end_date > 0:
    # Set end_date to 30 days from now as a default
    from datetime import datetime, timedelta
    default_end_date = datetime.utcnow() + timedelta(days=30)
    
    result = db.members.update_many(
        {"end_date": {"$exists": False}},
        {"$set": {"end_date": default_end_date}}
    )
    print(f"Updated {result.modified_count} members with a default end_date (30 days from now)")

# Update members without plan_id
if members_without_plan_id > 0:
    # Find a default plan to assign
    default_plan = db.plans.find_one({"is_active": True})
    
    if default_plan:
        result = db.members.update_many(
            {"plan_id": {"$exists": False}},
            {"$set": {"plan_id": default_plan["id"]}}
        )
        print(f"Updated {result.modified_count} members with a default plan_id")
    else:
        print("No active plans found to assign to members")

print("\nDatabase update complete!")