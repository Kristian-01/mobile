import csv
import firebase_admin
from firebase_admin import credentials, firestore
import time

# Initialize Firebase
cred = credentials.Certificate('firebase-key.json')
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
        return delete_collection(collection_name, batch_size) + deleted
    
    return deleted

# Delete existing collections
print("🗑️  Deleting existing data...")
print("-" * 60)

collections_to_delete = ['category', 'products', 'categories']
for collection in collections_to_delete:
    try:
        count = delete_collection(collection)
        if count > 0:
            print(f"✅ Deleted {count} documents from '{collection}' collection")
    except Exception as e:
        print(f"⚠️  Collection '{collection}' doesn't exist or error: {str(e)}")

print("-" * 60)
print("\n📤 Uploading new products to Firestore...")
print("=" * 60)

# Category mapping for display names
# Only pharmacy-related categories
category_display_names = {
    'MEDICINES': 'Medicines',
    'PERSONAL_CARE': 'Personal Care',
    'BABY_PRODUCTS': 'Baby Products',
    'MEDICAL_SUPPLIES': 'Medical Supplies',
    'FEMININE_CARE': 'Feminine Care',
    'OTHERS': 'Others'  # Includes Food, Beverages, Household Items, etc.
}

# Upload products from each CSV file
category_files = [
    'products_MEDICINES.csv',
    'products_PERSONAL_CARE.csv',
    'products_BABY_PRODUCTS.csv',
    'products_MEDICAL_SUPPLIES.csv',
    'products_FEMININE_CARE.csv',
    'products_OTHERS.csv'
]

total_uploaded = 0
category_stats = {}

for csv_file in category_files:
    try:
        # Extract category name from filename
        category_code = csv_file.replace('products_', '').replace('.csv', '')
        category_name = category_display_names.get(category_code, category_code)
        
        print(f"\n📁 Processing: {category_name}")
        
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            products_in_category = 0
            batch = db.batch()
            batch_count = 0
            
            for row in reader:
                product_name = row['Product Name'].strip()
                try:
                    stock = int(row['Stock Quantity'])
                except:
                    stock = 0
                
                # Create product document
                doc_ref = db.collection('products').document()
                batch.set(doc_ref, {
                    'name': product_name,
                    'stock': stock,
                    'category': category_name,
                    'categoryCode': category_code,
                    'createdAt': firestore.SERVER_TIMESTAMP,
                    'updatedAt': firestore.SERVER_TIMESTAMP
                })
                
                products_in_category += 1
                batch_count += 1
                total_uploaded += 1
                
                # Commit batch every 500 documents (Firestore limit)
                if batch_count >= 500:
                    batch.commit()
                    batch = db.batch()
                    batch_count = 0
                    print(f"  ⏳ Uploaded {products_in_category} products...")
            
            # Commit remaining items in batch
            if batch_count > 0:
                batch.commit()
            
            category_stats[category_name] = products_in_category
            print(f"  ✅ Uploaded {products_in_category} products from {category_name}")
            
    except FileNotFoundError:
        print(f"  ⚠️  File not found: {csv_file}")
    except Exception as e:
        print(f"  ❌ Error processing {csv_file}: {str(e)}")

# Create category summary documents
print("\n" + "=" * 60)
print("📊 Creating category summary...")
print("-" * 60)

for category_code, display_name in category_display_names.items():
    count = category_stats.get(display_name, 0)
    if count > 0:
        db.collection('categories').document(category_code).set({
            'name': display_name,
            'code': category_code,
            'productCount': count,
            'createdAt': firestore.SERVER_TIMESTAMP,
            'updatedAt': firestore.SERVER_TIMESTAMP
        })
        print(f"✅ {display_name}: {count} products")

print("=" * 60)
print(f"\n🎉 SUCCESS! Uploaded {total_uploaded} products to Firestore!")
print(f"📊 Project: mobile-e4ddd")
print(f"🔗 View at: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 60)
