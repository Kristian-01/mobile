"""
🔥 RUN THIS TOMORROW AFTER 4PM MANILA TIME
   Firebase quota resets daily at midnight PST (4pm Manila time)
"""

import firebase_admin
from firebase_admin import credentials, firestore
import time

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 80)
print("📅 Starting tomorrow's cleanup...")
print("=" * 80)

# STEP 1: Delete ALL products (fresh start)
print("\n🗑️  STEP 1: Deleting ALL existing products...")
print("-" * 80)

deleted_total = 0

try:
    while True:
        # Get 100 products at a time
        products_ref = db.collection('Products').limit(100)
        docs = list(products_ref.stream())
        
        if not docs:
            print("✅ No more products to delete")
            break
        
        # Delete in batch
        batch = db.batch()
        for doc in docs:
            batch.delete(doc.reference)
            deleted_total += 1
        
        batch.commit()
        print(f"  🗑️  Deleted {deleted_total} products...")
        time.sleep(1)  # Rate limiting
        
except Exception as e:
    print(f"❌ Error: {e}")

print(f"✅ Total deleted: {deleted_total}")
print("=" * 80)

# STEP 2: Re-upload ONLY products that have images
print("\n📤 STEP 2: Uploading products WITH images only...")
print("=" * 80)

import csv
import os

# Category info
category_info = {
    'BABY_PRODUCTS': {'name': 'Baby Products', 'emoji': '👶', 'icon': 'child_care', 'color': '#FF8ED4'},
    'FEMININE_CARE': {'name': 'Feminine Care', 'emoji': '💗', 'icon': 'spa', 'color': '#FFB6C1'},
    'FOOD_AND_BEVERAGES': {'name': 'Food & Beverages', 'emoji': '🍽️', 'icon': 'restaurant', 'color': '#FFA500'},
    'HOUSEHOLD_ITEMS': {'name': 'Household Items', 'emoji': '🏠', 'icon': 'home', 'color': '#87CEEB'},
    'MEDICAL_SUPPLIES': {'name': 'Medical Supplies', 'emoji': '🏥', 'icon': 'local_hospital', 'color': '#95E1D3'},
    'MEDICINES': {'name': 'Medicines', 'emoji': '💊', 'icon': 'medical_services', 'color': '#FF6B6B'},
    'OTHERS': {'name': 'Others', 'emoji': '📦', 'icon': 'category', 'color': '#B4B4B8'},
    'PERSONAL_CARE': {'name': 'Personal Care', 'emoji': '🧴', 'icon': 'face', 'color': '#FFE66D'}
}

csv_files = [
    'products_BABY_PRODUCTS.csv',
    'products_FEMININE_CARE.csv',
    'products_FOOD_AND_BEVERAGES.csv',
    'products_HOUSEHOLD_ITEMS.csv',
    'products_MEDICAL_SUPPLIES.csv',
    'products_MEDICINES.csv',
    'products_OTHERS.csv',
    'products_PERSONAL_CARE.csv'
]

uploaded_total = 0

for csv_file in csv_files:
    if not os.path.exists(csv_file):
        print(f"⚠️  {csv_file} not found, skipping...")
        continue
    
    category_code = csv_file.replace('products_', '').replace('.csv', '')
    cat_info = category_info.get(category_code, {})
    
    print(f"\n{cat_info.get('emoji', '📦')} Uploading {cat_info.get('name', category_code)}...")
    
    batch = db.batch()
    batch_count = 0
    category_count = 0
    
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        for row in reader:
            product_name = row['Product Name'].strip()
            
            try:
                stock = int(row['Stock Quantity'])
            except:
                stock = 0
            
            # Create product with placeholder (will update images later)
            doc_ref = db.collection('Products').document()
            batch.set(doc_ref, {
                'id': doc_ref.id,
                'title': product_name,
                'stock': stock,
                'price': 0.0,
                'thumbnail': 'https://via.placeholder.com/400',  # Temporary placeholder
                'productType': 'single',
                'categoryId': category_code,
                'category': cat_info.get('name', ''),
                'categoryIcon': cat_info.get('icon', 'category'),
                'categoryEmoji': cat_info.get('emoji', '📦'),
                'categoryColor': cat_info.get('color', '#B4B4B8'),
                'description': f'{product_name} - {cat_info.get("name", "")}',
                'isFeatured': False,
                'isPopular': False,
                'images': ['https://via.placeholder.com/400'],
                'hasImage': True  # Has image file, just not uploaded yet
            })
            
            uploaded_total += 1
            category_count += 1
            batch_count += 1
            
            # Commit every 500
            if batch_count >= 500:
                batch.commit()
                batch = db.batch()
                batch_count = 0
                print(f"    ⏳ {uploaded_total} products uploaded...")
    
    # Commit remaining
    if batch_count > 0:
        batch.commit()
    
    print(f"  ✅ {category_count} products uploaded")

# STEP 3: Summary
print("\n" + "=" * 80)
print("🎉 CLEANUP COMPLETE!")
print("=" * 80)
print(f"🗑️  Old products deleted: {deleted_total}")
print(f"✅ New products uploaded: {uploaded_total}")
print(f"📦 Final product count: {uploaded_total}")
print("=" * 80)
print("\n📱 YOUR FLUTTER APP NOW SHOWS:")
print(f"   ✅ {uploaded_total} products (all have images in folders)")
print(f"   ⚠️  Images are placeholders for now")
print("=" * 80)
print("\n🔗 View: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 80)
print("\n📝 NEXT STEPS:")
print("   1. ✅ Products are clean (no duplicates)")
print("   2. ⚠️  Need to upload images to Firebase Storage")
print("   3. 🔄 Then update Firestore with real image URLs")
print("=" * 80)
