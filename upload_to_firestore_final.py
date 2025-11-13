import csv
import firebase_admin
from firebase_admin import credentials, firestore
import random

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

collections_to_delete = ['Products', 'products', 'category', 'categories']
for collection in collections_to_delete:
    try:
        count = delete_collection(collection)
        if count > 0:
            print(f"✅ Deleted {count} documents from '{collection}' collection")
    except Exception as e:
        pass

print("-" * 60)
print("\n📤 Uploading products to Firestore...")
print("=" * 60)

# Category mapping with icons and placeholder images
category_info = {
    'MEDICINES': {
        'name': 'Medicines',
        'icon': 'medical_services',
        'emoji': '💊',
        'color': '#FF6B6B',
        'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400'
    },
    'PERSONAL_CARE': {
        'name': 'Personal Care',
        'icon': 'face',
        'emoji': '🧴',
        'color': '#FFE66D',
        'image': 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400'
    },
    'BABY_PRODUCTS': {
        'name': 'Baby Products',
        'icon': 'child_care',
        'emoji': '👶',
        'color': '#FF8ED4',
        'image': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=400'
    },
    'MEDICAL_SUPPLIES': {
        'name': 'Medical Supplies',
        'icon': 'local_hospital',
        'emoji': '🏥',
        'color': '#95E1D3',
        'image': 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=400'
    },
    'FEMININE_CARE': {
        'name': 'Feminine Care',
        'icon': 'spa',
        'emoji': '💗',
        'color': '#FFB6C1',
        'image': 'https://images.unsplash.com/photo-1607473256467-8bb5ffa2e4e6?w=400'
    },
    'OTHERS': {
        'name': 'Others',
        'icon': 'category',
        'emoji': '📦',
        'color': '#B4B4B8',
        'image': 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400'
    }
}

# CSV files to process
# Only pharmacy-related categories + Others for non-pharmacy items
category_files = [
    'products_MEDICINES.csv',
    'products_PERSONAL_CARE.csv',
    'products_BABY_PRODUCTS.csv',
    'products_MEDICAL_SUPPLIES.csv',
    'products_FEMININE_CARE.csv',
    'products_OTHERS.csv'  # Includes Food, Beverages, Household Items, etc.
]

all_products = []
category_stats = {}

# First pass: collect all products
for csv_file in category_files:
    try:
        category_code = csv_file.replace('products_', '').replace('.csv', '')
        cat_info = category_info.get(category_code, {})
        
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            
            for row in reader:
                product_name = row['Product Name'].strip()
                try:
                    stock = int(row['Stock Quantity'])
                except:
                    stock = 0
                
                # Create product data matching ProductModel structure
                product_data = {
                    'title': product_name,  # Using 'name' as 'title'
                    'stock': stock,
                    'price': 0.0,  # Default price, can be updated later
                    'thumbnail': cat_info.get('image', ''),  # Category image as thumbnail
                    'productType': 'single',
                    'categoryId': category_code,
                    'category': cat_info.get('name', ''),
                    'categoryIcon': cat_info.get('icon', 'category'),
                    'categoryEmoji': cat_info.get('emoji', '📦'),
                    'categoryColor': cat_info.get('color', '#B4B4B8'),
                    'description': f'{product_name} - {cat_info.get("name", "")}',
                    'isFeatured': False,  # Will be set later
                    'isPopular': False,   # Will be set later
                    'images': [cat_info.get('image', '')],
                }
                
                all_products.append(product_data)
                
                # Update stats
                cat_name = cat_info.get('name', category_code)
                category_stats[cat_name] = category_stats.get(cat_name, 0) + 1
                
    except FileNotFoundError:
        print(f"  ⚠️  File not found: {csv_file}")
    except Exception as e:
        print(f"  ❌ Error processing {csv_file}: {str(e)}")

print(f"📊 Total products loaded: {len(all_products)}")
print("-" * 60)

# Select 6 random products as featured
featured_indices = random.sample(range(len(all_products)), min(6, len(all_products)))
for idx in featured_indices:
    all_products[idx]['isFeatured'] = True

# Select 8 different products as popular (not featured)
non_featured_indices = [i for i in range(len(all_products)) if i not in featured_indices]
popular_indices = random.sample(non_featured_indices, min(8, len(non_featured_indices)))
for idx in popular_indices:
    all_products[idx]['isPopular'] = True

print(f"✨ Selected {len(featured_indices)} featured products")
print(f"🔥 Selected {len(popular_indices)} popular products")
print("-" * 60)

# Upload all products to Firestore
print("\n📤 Uploading to Firestore...")
batch = db.batch()
batch_count = 0
uploaded = 0

for product_data in all_products:
    doc_ref = db.collection('Products').document()
    product_data['id'] = doc_ref.id
    batch.set(doc_ref, product_data)
    
    batch_count += 1
    uploaded += 1
    
    # Commit batch every 500 documents
    if batch_count >= 500:
        batch.commit()
        batch = db.batch()
        batch_count = 0
        print(f"  ⏳ Uploaded {uploaded} products...")

# Commit remaining items
if batch_count > 0:
    batch.commit()

print(f"✅ Uploaded {uploaded} products!")
print("-" * 60)

# Create category documents
print("\n📊 Creating categories...")
for category_code, cat_info in category_info.items():
    count = category_stats.get(cat_info['name'], 0)
    if count > 0:
        db.collection('categories').document(category_code).set({
            'id': category_code,
            'name': cat_info['name'],
            'icon': cat_info['icon'],
            'emoji': cat_info['emoji'],
            'color': cat_info['color'],
            'image': cat_info['image'],
            'productCount': count,
            'isFeatured': True,
            'createdAt': firestore.SERVER_TIMESTAMP,
            'updatedAt': firestore.SERVER_TIMESTAMP
        })
        print(f"✅ {cat_info['emoji']} {cat_info['name']}: {count} products")

print("=" * 60)
print(f"\n🎉 SUCCESS! Setup complete!")
print(f"📊 Project: mobile-e4ddd")
print(f"✨ Featured Products: 6")
print(f"🔥 Popular Products: 8") 
print(f"📁 Categories: {len(category_info)}")
print(f"📦 Total Products: {len(all_products)}")
print(f"🔗 View at: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 60)
