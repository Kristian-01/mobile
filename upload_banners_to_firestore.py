import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# Initialize Firebase
cred = credentials.Certificate('firebase-key.json')
try:
    firebase_admin.get_app()
except:
    firebase_admin.initialize_app(cred)
db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 60)

# Function to delete all documents in a collection
def delete_collection(collection_name, batch_size=100):
    """Delete all documents in a collection"""
    coll_ref = db.collection(collection_name)
    docs = coll_ref.limit(batch_size).stream()
    deleted = 0
    
    for doc in docs:
        doc.reference.delete()
        deleted += 1
    
    if deleted >= batch_size:
        return delete_collection(collection_name, batch_size)
    
    return deleted

# Delete existing banners
print("🗑️  Deleting old banners...")
deleted_count = delete_collection('Banners')
print(f"✅ Deleted {deleted_count} old banners")
print("=" * 60)

# New banner data
banners = [
    {
        'imageUrl': 'assets/images/banners/banner1.png',
        'title': 'Exclusive Deals',
        'subtitle': 'Save More on Every Order - Exclusive Deals On Nine27 Pharmacy',
        'targetScreen': 'Store',
        'categoryId': None,
        'productId': None,
        'isActive': True,
        'order': 1,
    },
    {
        'imageUrl': 'assets/images/banners/banner2.png',
        'title': 'Medicine Categories',
        'subtitle': 'Browse for suitable medicine categories and find the medications and easily specials available',
        'targetScreen': 'Categories',
        'categoryId': None,
        'productId': None,
        'isActive': True,
        'order': 2,
    },
    {
        'imageUrl': 'assets/images/banners/banner3.jpg',
        'title': 'Vitamins Sale',
        'subtitle': '20% off vitamins',
        'targetScreen': 'Store',
        'categoryId': None,
        'productId': None,
        'isActive': True,
        'order': 3,
    },
    {
        'imageUrl': 'assets/images/banners/banner4.png',
        'title': 'Featured Medicines',
        'subtitle': 'Featured Medicines on Sale - Achiez27 Pharmacy, be sure to check out the innovations',
        'targetScreen': 'Store',
        'categoryId': None,
        'productId': None,
        'isActive': True,
        'order': 4,
    },
    {
        'imageUrl': 'assets/images/banners/banner5.png',
        'title': 'Nine27 Pharmacy',
        'subtitle': 'Navigate and decide certain top options',
        'targetScreen': 'Store',
        'categoryId': None,
        'productId': None,
        'isActive': True,
        'order': 5,
    },
]

# Upload new banners
print("📤 Uploading new banners...")
for idx, banner in enumerate(banners, 1):
    try:
        doc_ref = db.collection('Banners').add(banner)
        print(f"✅ Banner {idx}: {banner['title']} - Uploaded!")
    except Exception as e:
        print(f"❌ Error uploading banner {idx}: {str(e)}")

print("=" * 60)
print("✨ Banner upload complete!")
print("=" * 60)

# Verify upload
banners_ref = db.collection('Banners').order_by('order').stream()
print("\n📋 Current banners in Firestore:")
for banner in banners_ref:
    data = banner.to_dict()
    print(f"  {data['order']}. {data['title']} - Active: {data['isActive']}")

print("\n✅ All done!")
