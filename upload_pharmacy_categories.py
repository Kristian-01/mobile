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

# Pharmacy category mapping with local asset images
pharmacy_categories = [
    {
        'id': 'baby_products',
        'name': 'Baby Products',
        'image': 'assets/icons/categories/baby-products.png',
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'feminine_care',
        'name': 'Feminine Care',
        'image': 'assets/icons/categories/feminine-care.png',
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'medicines',
        'name': 'Medicines',
        'image': 'assets/icons/categories/medicines.png',
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'medical_supplies',
        'name': 'Medical Supplies',
        'image': 'assets/icons/categories/medical-supplies.png',
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'personal_care',
        'name': 'Personal Care',
        'image': 'assets/icons/categories/personal-care.png',
        'isFeatured': True,
        'parentId': None,
    },
    {
        'id': 'others',
        'name': 'Others',
        'image': 'assets/icons/categories/others.png',
        'isFeatured': True,
        'parentId': None,
    }
]

print("📤 Uploading pharmacy categories to Firestore...")
print("-" * 60)

# Upload categories to Firestore
for category in pharmacy_categories:
    try:
        db.collection('categories').document(category['id']).set(category)
        print(f"✅ Uploaded: {category['name']} ({category['id']})")
    except Exception as e:
        print(f"❌ Error uploading {category['name']}: {str(e)}")

print("-" * 60)
print("✨ Pharmacy categories uploaded successfully!")
print("=" * 60)
print("\n📝 Next Steps:")
print("1. Save the 6 category images to: c:\\Projects\\capstone\\mobile3\\assets\\icons\\categories\\")
print("   - baby-products.png (Image 1: baby onesie, bib, bottle)")
print("   - feminine-care.png (Image 2: female symbol in hand)")
print("   - medicines.png (Image 3: pills/capsules)")
print("   - medical-supplies.png (Image 4: medical/first aid kit)")
print("   - personal-care.png (Image 5: pump bottles)")
print("   - others.png (Image 6: generic boxes)")
print("\n2. Run: flutter pub get")
print("3. Restart your app to see the new category images")
