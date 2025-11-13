import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate('firebase-key.json')
try:
    firebase_admin.get_app()
except:
    firebase_admin.initialize_app(cred)
db = firestore.client()

print("🔍 Checking Banners in Firestore...")
print("=" * 60)

# Fetch all banners
banners_ref = db.collection('Banners').order_by('order').stream()

count = 0
for banner in banners_ref:
    count += 1
    data = banner.to_dict()
    print(f"\n📌 Banner {count}:")
    print(f"   ID: {banner.id}")
    print(f"   Title: {data.get('title')}")
    print(f"   Image URL: {data.get('imageUrl')}")
    print(f"   Active: {data.get('isActive')}")
    print(f"   Order: {data.get('order')}")

print("\n" + "=" * 60)
print(f"✅ Total banners found: {count}")
