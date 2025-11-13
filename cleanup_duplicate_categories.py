import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate('firebase-key.json')
try:
    firebase_admin.get_app()
except:
    firebase_admin.initialize_app(cred)
db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 60)

# Expected 6 pharmacy categories
expected_categories = [
    'baby_products',
    'feminine_care',
    'medicines',
    'medical_supplies',
    'personal_care',
    'others'
]

print("📋 Fetching all categories from Firestore...")
categories_ref = db.collection('categories')
all_categories = categories_ref.get()

print(f"\n📊 Total categories found: {len(all_categories)}")
print("-" * 60)

# Group categories by name to find duplicates
categories_by_name = {}
for cat in all_categories:
    data = cat.to_dict()
    name = data.get('name', 'Unknown')
    
    if name not in categories_by_name:
        categories_by_name[name] = []
    
    categories_by_name[name].append({
        'id': cat.id,
        'data': data
    })
    
    print(f"Found: {name} (ID: {cat.id})")

print("-" * 60)

# Find and remove duplicates
duplicates_found = False
for name, cats in categories_by_name.items():
    if len(cats) > 1:
        duplicates_found = True
        print(f"\n⚠️  DUPLICATE: {name} ({len(cats)} copies)")
        
        # Keep the first one with expected ID, delete others
        expected_id = None
        for expected in expected_categories:
            if expected.replace('_', ' ').title() == name or expected.replace('_', ' ').lower() == name.lower():
                expected_id = expected
                break
        
        kept = None
        for cat in cats:
            if cat['id'] == expected_id:
                kept = cat
                print(f"  ✅ Keeping: {cat['id']}")
                break
        
        # If no expected ID match, keep first one
        if not kept:
            kept = cats[0]
            print(f"  ✅ Keeping: {kept['id']} (first one)")
        
        # Delete others
        for cat in cats:
            if cat['id'] != kept['id']:
                print(f"  ❌ Deleting: {cat['id']}")
                db.collection('categories').document(cat['id']).delete()

if not duplicates_found:
    print("\n✅ No duplicates found!")
else:
    print("\n✨ Duplicate cleanup completed!")

# Show final count
final_categories = categories_ref.get()
print("=" * 60)
print(f"📊 Final category count: {len(final_categories)}")
print("=" * 60)
