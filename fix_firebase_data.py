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

# Step 1: Delete uppercase category IDs (keep only lowercase)
print("\n🗑️  STEP 1: Cleaning up duplicate categories...")
print("-" * 60)
uppercase_categories = ['BABY_PRODUCTS', 'FEMININE_CARE', 'MEDICAL_SUPPLIES', 'MEDICINES', 'OTHERS', 'PERSONAL_CARE']

for cat_id in uppercase_categories:
    db.collection('categories').document(cat_id).delete()
    print(f"  ❌ Deleted: {cat_id}")

print("✅ Cleaned up uppercase category duplicates")

# Step 2: Update all products to use lowercase categoryIds
print("\n🔄 STEP 2: Updating products to use lowercase categoryIds...")
print("-" * 60)

category_mapping = {
    'BABY_PRODUCTS': 'baby_products',
    'FEMININE_CARE': 'feminine_care',
    'MEDICAL_SUPPLIES': 'medical_supplies',
    'MEDICINES': 'medicines',
    'OTHERS': 'others',
    'PERSONAL_CARE': 'personal_care',
}

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
        
        updated_count += 1
        if updated_count <= 10:  # Show first 10
            print(f"  ✅ {product_data.get('title', product_data.get('name', 'Unknown'))}: {old_category} → {new_category}")

print(f"\n✨ Updated {updated_count} products!")

# Step 3: Verify the fix
print("\n✅ STEP 3: Verification")
print("-" * 60)
categories = db.collection('categories').get()
print(f"Categories: {len(categories)} (should be 6)")

sample_products = db.collection('Products').limit(3).get()
print(f"\nSample products:")
for prod in sample_products:
    data = prod.to_dict()
    print(f"  - {data.get('title', data.get('name'))}: {data.get('categoryId')}")

print("\n" + "=" * 60)
print("✨ All done! Restart your Flutter app now!")
print("=" * 60)
