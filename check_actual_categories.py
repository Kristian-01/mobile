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
print("=" * 80)

# Check categories
print("\n📂 CATEGORIES IN FIRESTORE:")
print("-" * 80)
categories_ref = db.collection('categories').get()
for cat in categories_ref:
    cat_data = cat.to_dict()
    print(f"  ✅ {cat_data.get('name', 'Unknown'):20s} (ID: {cat.id})")

print(f"\nTotal Categories: {len(categories_ref)}")

# Check products
print("\n" + "=" * 80)
print("📦 PRODUCTS IN FIRESTORE:")
print("-" * 80)
products_ref = db.collection('Products').get()
print(f"Total Products: {len(products_ref)}")

# Count by category
from collections import defaultdict
category_count = defaultdict(int)

for product in products_ref:
    product_data = product.to_dict()
    cat_id = product_data.get('categoryId', 'Unknown')
    category_count[cat_id] += 1

print("\n📊 Products per Category:")
print("-" * 80)
for cat_id, count in sorted(category_count.items(), key=lambda x: x[1], reverse=True):
    print(f"  {cat_id:25s}: {count:4d} products")

print("=" * 80)
