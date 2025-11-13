import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Checking Firestore Products...")
print("=" * 80)

try:
    # Get first 10 products to check
    products_ref = db.collection('Products').limit(10)
    docs = list(products_ref.stream())
    
    print(f"\n📊 Sample of first 10 products:")
    print("-" * 80)
    
    for i, doc in enumerate(docs, 1):
        data = doc.to_dict()
        title = data.get('title', 'N/A')
        thumbnail = data.get('thumbnail', 'N/A')
        has_placeholder = 'placeholder' in thumbnail.lower()
        
        print(f"{i}. {title}")
        print(f"   Image: {thumbnail[:60]}...")
        print(f"   Placeholder: {'YES ❌' if has_placeholder else 'NO ✅'}")
        print()
    
    print("=" * 80)
    print("\n✅ Check complete!")
    print("\n🔗 View all: https://console.firebase.google.com/project/mobile-e4ddd/firestore/databases/-default-/data/~2FProducts")
    print("=" * 80)
    
except Exception as e:
    print(f"❌ Error: {e}")
