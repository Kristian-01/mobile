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

# Check categories
print("\n📁 CATEGORIES:")
print("-" * 60)
categories_ref = db.collection('categories')
all_categories = categories_ref.get()
print(f"Found {len(all_categories)} categories:")
for cat in all_categories:
    data = cat.to_dict()
    print(f"  - {cat.id}: {data.get('name', 'N/A')}")

# Check products (try both uppercase and lowercase)
print("\n📦 PRODUCTS (lowercase 'products'):")
print("-" * 60)
products_ref = db.collection('products')
products = products_ref.limit(5).get()
print(f"Found {len(products)} products (showing first 5):")
for prod in products:
    data = prod.to_dict()
    print(f"  - {data.get('name', data.get('title', 'N/A'))}: categoryId={data.get('categoryId', data.get('category', 'N/A'))}")

print("\n📦 PRODUCTS (uppercase 'Products'):")
print("-" * 60)
products_ref2 = db.collection('Products')
products2 = products_ref2.limit(5).get()
print(f"Found {len(products2)} products (showing first 5):")
for prod in products2:
    data = prod.to_dict()
    print(f"  - {data.get('title', data.get('name', 'N/A'))}: categoryId={data.get('categoryId', 'N/A')}")

print("\n" + "=" * 60)
