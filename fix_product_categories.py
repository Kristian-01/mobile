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

# Map old category IDs to new ones
category_mapping = {
    'multivitamins': 'medicines',
    'medicines': 'medicines',
    'topical_oral': 'medical_supplies',
    'cough_cold': 'medicines',
    'baby_care': 'baby_products',
    'skin_beauty': 'personal_care',
    'oral_care': 'personal_care',
    'hair_care': 'personal_care',
    'deodorants': 'personal_care',
}

print("🔄 Updating product categoryIds to match existing categories...")
print("-" * 60)

# Get all products
products_ref = db.collection('Products')
all_products = products_ref.get()

updated_count = 0
for product_doc in all_products:
    product_data = product_doc.to_dict()
    old_category = product_data.get('categoryId')
    
    if old_category in category_mapping:
        new_category = category_mapping[old_category]
        
        # Update the product
        product_doc.reference.update({
            'categoryId': new_category
        })
        
        print(f"✅ {product_data.get('title', 'Unknown')}: {old_category} → {new_category}")
        updated_count += 1

print("-" * 60)
print(f"✨ Updated {updated_count} products!")
print("=" * 60)
print("\n🔄 Next Steps:")
print("1. Hot restart your Flutter app")
print("2. Products should now appear in categories!")
