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
print("=" * 80)

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
print("-" * 80)

collections_to_delete = ['Products', 'products', 'category', 'categories']
for collection in collections_to_delete:
    try:
        count = delete_collection(collection)
        if count > 0:
            print(f"✅ Deleted {count} documents from '{collection}' collection")
    except Exception as e:
        pass

print("-" * 80)
print("\n📤 Uploading products to Firestore...")
print("=" * 80)

# Category mapping with icons and placeholder images - ALL 8 CATEGORIES
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
    'FOOD_AND_BEVERAGES': {
        'name': 'Food & Beverages',
        'icon': 'restaurant',
        'emoji': '🍽️',
        'color': '#FFA500',
        'image': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400'
    },
    'HOUSEHOLD_ITEMS': {
        'name': 'Household Items',
        'icon': 'home',
        'emoji': '🏠',
        'color': '#87CEEB',
        'image': 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=400'
    },
    'OTHERS': {
        'name': 'Others',
        'icon': 'category',
        'emoji': '📦',
        'color': '#B4B4B8',
        'image': 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400'
    }
}

# CSV files to process - ALL 8 CATEGORIES
category_files = [
    'products_MEDICINES.csv',
    'products_PERSONAL_CARE.csv',
    'products_BABY_PRODUCTS.csv',
    'products_MEDICAL_SUPPLIES.csv',
    'products_FEMININE_CARE.csv',
    'products_FOOD_AND_BEVERAGES.csv',
    'products_HOUSEHOLD_ITEMS.csv',
    'products_OTHERS.csv'
]

all_products = []
category_stats = {}

# First pass: collect all products
print("📂 Reading CSV files...")
print("-" * 80)

for csv_file in category_files:
    try:
        category_code = csv_file.replace('products_', '').replace('.csv', '')
        cat_info = category_info.get(category_code, {})
        
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            products_in_file = 0
            
            for row in reader:
                product_name = row['Product Name'].strip()
                try:
                    stock = int(row['Stock Quantity'])
                except:
                    stock = 0
                
                # Create product data matching ProductModel structure
                product_data = {
                    'title': product_name,
                    'stock': stock,
                    'price': 0.0,  # Default price, can be updated later
                    'thumbnail': cat_info.get('image', ''),
                    'productType': 'single',
                    'categoryId': category_code,
                    'category': cat_info.get('name', ''),
                    'categoryIcon': cat_info.get('icon', 'category'),
                    'categoryEmoji': cat_info.get('emoji', '📦'),
                    'categoryColor': cat_info.get('color', '#B4B4B8'),
                    'description': f'{product_name} - {cat_info.get("name", "")}',
                    'isFeatured': False,
                    'isPopular': False,
                    'images': [cat_info.get('image', '')],
                }
                
                all_products.append(product_data)
                products_in_file += 1
                
                # Update stats
                cat_name = cat_info.get('name', category_code)
                category_stats[cat_name] = category_stats.get(cat_name, 0) + 1
        
        print(f"  ✅ {cat_info.get('emoji', '📦')} {cat_info.get('name', category_code)}: {products_in_file} products")
                
    except FileNotFoundError:
        print(f"  ⚠️  File not found: {csv_file}")
    except Exception as e:
        print(f"  ❌ Error processing {csv_file}: {str(e)}")

print("-" * 80)
print(f"📊 Total products loaded: {len(all_products)}")
print("-" * 80)

# Select random products as featured and popular
if len(all_products) > 0:
    # Select 6 random products as featured
    num_featured = min(6, len(all_products))
    featured_indices = random.sample(range(len(all_products)), num_featured)
    for idx in featured_indices:
        all_products[idx]['isFeatured'] = True

    # Select 8 different products as popular (not featured)
    non_featured_indices = [i for i in range(len(all_products)) if i not in featured_indices]
    num_popular = min(8, len(non_featured_indices))
    if num_popular > 0:
        popular_indices = random.sample(non_featured_indices, num_popular)
        for idx in popular_indices:
            all_products[idx]['isPopular'] = True
    
    print(f"✨ Selected {num_featured} featured products")
    print(f"🔥 Selected {num_popular} popular products")
    print("-" * 80)

# Upload all products to Firestore
print("\n📤 Uploading to Firestore...")
print("-" * 80)

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

print(f"✅ Uploaded {uploaded} products to Firestore!")
print("-" * 80)

# Create category documents
print("\n📊 Creating categories...")
print("-" * 80)

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
        print(f"  ✅ {cat_info['emoji']} {cat_info['name']}: {count} products")

print("=" * 80)
print(f"\n🎉 SUCCESS! All products uploaded!")
print("=" * 80)
print(f"📊 Project: mobile-e4ddd")
print(f"✨ Featured Products: {num_featured}")
print(f"🔥 Popular Products: {num_popular}") 
print(f"📁 Total Categories: {len([c for c in category_stats.values() if c > 0])}")
print(f"📦 Total Products: {len(all_products)}")
print(f"🔗 View at: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 80)
print("\n✅ All products with images have been uploaded to Firestore!")
print("=" * 80)
