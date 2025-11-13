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

# First, delete ALL existing categories to clean up duplicates
print("🗑️  Deleting all existing categories...")
categories_ref = db.collection('categories')
all_categories = categories_ref.get()

for cat in all_categories:
    cat.reference.delete()
    print(f"  ❌ Deleted: {cat.id}")

print(f"✅ Deleted {len(all_categories)} categories")
print("-" * 60)

# Now upload fresh 6 categories with Material Icons
pharmacy_categories = [
    {
        'id': 'baby_products',
        'name': 'Baby Products',
        'icon': 'child_care',  # Material icon name
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'feminine_care',
        'name': 'Feminine Care',
        'icon': 'female',  # Material icon name
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'medicines',
        'name': 'Medicines',
        'icon': 'medication',  # Material icon name
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'medical_supplies',
        'name': 'Medical Supplies',
        'icon': 'medical_services',  # Material icon name
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'personal_care',
        'name': 'Personal Care',
        'icon': 'soap',  # Material icon name
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'others',
        'name': 'Others',
        'icon': 'category',  # Material icon name
        'isFeatured': True,
        'parentId': None,
    }
]

print("📤 Uploading 6 pharmacy categories with icons...")
print("-" * 60)

for category in pharmacy_categories:
    try:
        db.collection('categories').document(category['id']).set(category)
        print(f"✅ Uploaded: {category['name']} (icon: {category['icon']})")
    except Exception as e:
        print(f"❌ Error uploading {category['name']}: {str(e)}")

print("-" * 60)
print("✨ Categories updated successfully!")
print(f"📊 Total categories: {len(pharmacy_categories)}")
print("=" * 60)
print("\n🔄 Next Steps:")
print("1. Hot restart your Flutter app (press R)")
print("2. Categories will now show with Material Icons")
print("3. No need to download images!")
