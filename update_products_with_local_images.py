import os
import re
import csv
import firebase_admin
from firebase_admin import credentials, firestore
import shutil

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 80)

# Image folder paths
image_folders = {
    'BABY_PRODUCTS': r'c:\Users\kristian\img\images_baby_products',
    'FEMININE_CARE': r'c:\Users\kristian\img\images_female_care',
    'FOOD_AND_BEVERAGES': r'c:\Users\kristian\img\images_food_and_beverages',
    'HOUSEHOLD_ITEMS': r'c:\Users\kristian\img\images_household_items',
    'MEDICAL_SUPPLIES': r'c:\Users\kristian\img\images_medical_supplies',
    'MEDICINES': r'c:\Users\kristian\img\images_medicine',
    'OTHERS': r'c:\Users\kristian\img\images_others',
    'PERSONAL_CARE': r'c:\Users\kristian\img\images_personal_care'
}

# CSV files
csv_files = {
    'BABY_PRODUCTS': 'products_BABY_PRODUCTS.csv',
    'FEMININE_CARE': 'products_FEMININE_CARE.csv',
    'FOOD_AND_BEVERAGES': 'products_FOOD_AND_BEVERAGES.csv',
    'HOUSEHOLD_ITEMS': 'products_HOUSEHOLD_ITEMS.csv',
    'MEDICAL_SUPPLIES': 'products_MEDICAL_SUPPLIES.csv',
    'MEDICINES': 'products_MEDICINES.csv',
    'OTHERS': 'products_OTHERS.csv',
    'PERSONAL_CARE': 'products_PERSONAL_CARE.csv'
}

def normalize_name(name):
    """Normalize product/image name for comparison"""
    # Remove file extensions
    name = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', name, flags=re.IGNORECASE)
    # Convert to lowercase
    name = name.lower()
    # Remove special characters and extra spaces
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    return name.strip()

def find_matching_image(product_name, category_images):
    """Find matching image for a product"""
    normalized_product = normalize_name(product_name)
    
    best_match = None
    best_match_score = 0
    
    for image_file, image_path in category_images:
        normalized_image = normalize_name(image_file)
        
        # Exact match
        if normalized_product == normalized_image:
            return image_file, image_path
        
        # Check if product name is in image name or vice versa
        if normalized_product in normalized_image:
            match_score = len(normalized_product) / max(len(normalized_image), 1)
            if match_score > best_match_score:
                best_match = (image_file, image_path)
                best_match_score = match_score
        elif normalized_image in normalized_product:
            match_score = len(normalized_image) / max(len(normalized_product), 1)
            if match_score > best_match_score:
                best_match = (image_file, image_path)
                best_match_score = match_score
    
    # Return match if score is good enough
    if best_match_score > 0.6:
        return best_match
    
    return None, None

# Step 1: Scan all images
print("📂 Scanning image folders...")
print("-" * 80)

all_images = {}
total_images = 0

for category, folder in image_folders.items():
    images = []
    if os.path.exists(folder):
        for file in os.listdir(folder):
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
                full_path = os.path.join(folder, file)
                images.append((file, full_path))
                total_images += 1
        all_images[category] = images
        print(f"  ✅ {category}: {len(images)} images")
    else:
        print(f"  ⚠️  {category}: Folder not found")
        all_images[category] = []

print("-" * 80)
print(f"📊 Total images found: {total_images}")
print("-" * 80)

# Step 2: Build a comprehensive product-to-image mapping
print("\n🔍 Building product-image mappings...")
print("=" * 80)

product_image_map = {}
products_with_images = set()
products_without_images = set()

for category in csv_files.keys():
    csv_file = csv_files[category]
    
    if not os.path.exists(csv_file):
        print(f"  ⚠️  CSV not found: {csv_file}")
        continue
    
    category_images = all_images.get(category, [])
    
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        for row in reader:
            product_name = row['Product Name'].strip()
            
            # Find matching image
            image_file, image_path = find_matching_image(product_name, category_images)
            
            if image_file and image_path:
                product_image_map[product_name] = {
                    'category': category,
                    'image_file': image_file,
                    'image_path': image_path
                }
                products_with_images.add(product_name)
            else:
                products_without_images.add(product_name)

print(f"✅ Products with images: {len(products_with_images)}")
print(f"❌ Products without images: {len(products_without_images)}")
print("-" * 80)

# Step 3: Get all Firestore products and update/delete
print("\n📦 Updating Firestore products...")
print("=" * 80)

products_ref = db.collection('Products')
all_firestore_products = products_ref.stream()

updated_count = 0
deleted_count = 0
not_found_count = 0

for doc in all_firestore_products:
    product_data = doc.to_dict()
    product_name = product_data.get('title', '')
    doc_id = doc.id
    
    if product_name in product_image_map:
        # Product has an image - update with image path
        image_info = product_image_map[product_name]
        image_path = image_info['image_path']
        
        # For now, store the local file path
        # Later you can upload these to a CDN or Firebase Storage
        try:
            db.collection('Products').document(doc_id).update({
                'thumbnail': image_path,
                'images': [image_path],
                'hasImage': True,
                'imageFileName': image_info['image_file']
            })
            updated_count += 1
            if updated_count % 50 == 0:
                print(f"  ⏳ Updated {updated_count} products...")
        except Exception as e:
            print(f"  ❌ Error updating {product_name}: {e}")
    else:
        # Product doesn't have an image - delete it
        try:
            db.collection('Products').document(doc_id).delete()
            deleted_count += 1
            if deleted_count % 50 == 0:
                print(f"  🗑️  Deleted {deleted_count} products...")
        except Exception as e:
            print(f"  ❌ Error deleting {product_name}: {e}")

# Final Summary
print("\n" + "=" * 80)
print("🎉 PROCESS COMPLETE!")
print("=" * 80)
print(f"✅ Products updated with images: {updated_count}")
print(f"🗑️  Products deleted (no images): {deleted_count}")
print(f"📦 Final product count: {updated_count}")
print("-" * 80)
print(f"📂 Total images available: {total_images}")
print(f"✅ Products with matched images: {len(products_with_images)}")
print(f"❌ Products without images: {len(products_without_images)}")
print("=" * 80)
print(f"\n🔗 View at: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 80)
print("\n⚠️  NOTE: Products now have LOCAL file paths.")
print("   To make images accessible online, you need to:")
print("   1. Enable Firebase Storage and upload images, OR")
print("   2. Upload images to a CDN/hosting service")
print("=" * 80)
