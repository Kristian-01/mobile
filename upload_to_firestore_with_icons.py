import csv
import firebase_admin
from firebase_admin import credentials, firestore
import time

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
print("\n📤 Uploading new products to Firestore with icons...")
print("=" * 60)

# Category mapping with icons
category_info = {
    'MEDICINES': {
        'name': 'Medicines',
        'icon': 'medical_services',  # Material Icon name
        'emoji': '💊',
        'color': '#FF6B6B'
    },
    'FOOD_AND_BEVERAGES': {
        'name': 'Food & Beverages',
        'icon': 'restaurant',
        'emoji': '🍔',
        'color': '#4ECDC4'
    },
    'PERSONAL_CARE': {
        'name': 'Personal Care',
        'icon': 'face',
        'emoji': '🧴',
        'color': '#FFE66D'
    },
    'BABY_PRODUCTS': {
        'name': 'Baby Products',
        'icon': 'child_care',
        'emoji': '👶',
        'color': '#FF8ED4'
    },
    'MEDICAL_SUPPLIES': {
        'name': 'Medical Supplies',
        'icon': 'local_hospital',
        'emoji': '🏥',
        'color': '#95E1D3'
    },
    'HOUSEHOLD_ITEMS': {
        'name': 'Household Items',
        'icon': 'home',
        'emoji': '🏠',
        'color': '#A8E6CF'
    },
    'FEMININE_CARE': {
        'name': 'Feminine Care',
        'icon': 'spa',
        'emoji': '💗',
        'color': '#FFB6C1'
    },
    'OTHERS': {
        'name': 'Others',
        'icon': 'category',
        'emoji': '📦',
        'color': '#B4B4B8'
    }
}

# Upload products from each CSV file
category_files = [
    'products_MEDICINES.csv',
    'products_FOOD_AND_BEVERAGES.csv',
    'products_PERSONAL_CARE.csv',
    'products_BABY_PRODUCTS.csv',
    'products_MEDICAL_SUPPLIES.csv',
    'products_HOUSEHOLD_ITEMS.csv',
    'products_FEMININE_CARE.csv',
    'products_OTHERS.csv'
]

total_uploaded = 0
category_stats = {}

for csv_file in category_files:
    try:
        # Extract category name from filename
        category_code = csv_file.replace('products_', '').replace('.csv', '')
        cat_info = category_info.get(category_code, {})
        category_name = cat_info.get('name', category_code)
        category_icon = cat_info.get('icon', 'category')
        category_emoji = cat_info.get('emoji', '📦')
        category_color = cat_info.get('color', '#B4B4B8')
        
        print(f"\n📁 Processing: {category_emoji} {category_name}")
        
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
                
                # Create product document with icon
                doc_ref = db.collection('products').document()
                batch.set(doc_ref, {
                    'name': product_name,
                    'stock': stock,
                    'category': category_name,
                    'categoryCode': category_code,
                    'icon': category_icon,  # Material Icon name
                    'emoji': category_emoji,  # Emoji fallback
                    'color': category_color,  # Category color
                    'imageUrl': '',  # Placeholder for future image
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

# Create category summary documents with icons
print("\n" + "=" * 60)
print("📊 Creating category summary with icons...")
print("-" * 60)

for category_code, cat_info in category_info.items():
    display_name = cat_info['name']
    count = category_stats.get(display_name, 0)
    if count > 0:
        db.collection('categories').document(category_code).set({
            'name': display_name,
            'code': category_code,
            'icon': cat_info['icon'],  # Material Icon name for Flutter
            'emoji': cat_info['emoji'],  # Emoji
            'color': cat_info['color'],  # Hex color
            'productCount': count,
            'imageUrl': '',  # Placeholder for future category image
            'createdAt': firestore.SERVER_TIMESTAMP,
            'updatedAt': firestore.SERVER_TIMESTAMP
        })
        print(f"✅ {cat_info['emoji']} {display_name}: {count} products")

print("=" * 60)
print(f"\n🎉 SUCCESS! Uploaded {total_uploaded} products to Firestore!")
print(f"📊 Project: mobile-e4ddd")
print(f"🎨 All products now have category icons!")
print(f"🔗 View at: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 60)
print("\n📝 Icon Fields Added:")
print("   • icon: Material Icon name (for Flutter)")
print("   • emoji: Emoji fallback")
print("   • color: Category color code")
print("   • imageUrl: Empty (ready for your images)")
print("=" * 60)
