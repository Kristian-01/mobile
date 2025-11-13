import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Checking Products in Firestore...")
print("=" * 80)

# Get 5 random products to check
products_ref = db.collection('Products').limit(5)
docs = list(products_ref.stream())

print(f"\n📊 Sample of 5 products:")
print("-" * 80)

placeholder_count = 0
localhost_count = 0
real_url_count = 0

for i, doc in enumerate(docs, 1):
    data = doc.to_dict()
    title = data.get('title', 'N/A')
    thumbnail = data.get('thumbnail', 'N/A')
    
    print(f"\n{i}. {title}")
    print(f"   URL: {thumbnail}")
    
    if 'placeholder' in thumbnail.lower():
        print(f"   Status: ❌ PLACEHOLDER")
        placeholder_count += 1
    elif 'localhost' in thumbnail.lower():
        print(f"   Status: ⚠️  LOCALHOST (works on PC only)")
        localhost_count += 1
    else:
        print(f"   Status: ✅ REAL URL")
        real_url_count += 1

print("\n" + "=" * 80)
print("📊 SUMMARY (from sample):")
print("-" * 80)
print(f"❌ Placeholders: {placeholder_count}")
print(f"⚠️  Localhost URLs: {localhost_count}")
print(f"✅ Real URLs: {real_url_count}")
print("=" * 80)

if localhost_count > 0:
    print("\n⚠️  YOUR PRODUCTS USE LOCALHOST URLs")
    print("   This means images ONLY work on your computer!")
    print("   For production, you need to deploy images online.")
elif placeholder_count > 0:
    print("\n❌ STILL HAVE PLACEHOLDERS!")
    print("   Need to run image update script.")
else:
    print("\n✅ ALL GOOD! Products have real online URLs!")

print("=" * 80)
