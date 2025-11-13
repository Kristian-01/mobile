import os
import re
import csv
import firebase_admin
from firebase_admin import credentials, firestore
import requests
import base64
import time
from pathlib import Path

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 80)

# ImgBB API Configuration
IMGBB_API_KEY = "e0ced2c1a8ca604b7780f01b08b00f29"
IMGBB_UPLOAD_URL = "https://api.imgbb.com/1/upload"

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
    name = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', name, flags=re.IGNORECASE)
    name = name.lower()
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    return name.strip()

def upload_to_imgbb(image_path, image_name):
    """Upload image to ImgBB and return URL"""
    try:
        with open(image_path, 'rb') as file:
            # Read and encode image
            image_data = base64.b64encode(file.read()).decode('utf-8')
            
            # Prepare payload
            payload = {
                'key': IMGBB_API_KEY,
                'image': image_data,
                'name': image_name
            }
            
            # Upload
            response = requests.post(IMGBB_UPLOAD_URL, data=payload)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    return result['data']['url']
                else:
                    print(f"    ❌ ImgBB Error: {result.get('error', {}).get('message', 'Unknown error')}")
                    return None
            else:
                print(f"    ❌ HTTP Error {response.status_code}: {response.text[:100]}")
                return None
                
    except Exception as e:
        print(f"    ❌ Upload error: {e}")
        return None

def find_matching_image(product_name, category_images):
    """Find matching image for a product"""
    normalized_product = normalize_name(product_name)
    
    best_match = None
    best_match_score = 0
    
    for image_file, image_path in category_images:
        normalized_image = normalize_name(image_file)
        
        if normalized_product == normalized_image:
            return image_file, image_path
        
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
    
    if best_match_score > 0.6:
        return best_match
    
    return None, None

# Check API key
if IMGBB_API_KEY == "YOUR_API_KEY_HERE":
    print("❌ ERROR: Please set your ImgBB API key!")
    print("=" * 80)
    print("Steps to get API key:")
    print("1. Go to: https://api.imgbb.com/")
    print("2. Click 'Get API Key'")
    print("3. Sign up or login")
    print("4. Copy your API key")
    print("5. Replace 'YOUR_API_KEY_HERE' in this script")
    print("=" * 80)
    exit(1)

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
        all_images[category] = []

print("-" * 80)
print(f"📊 Total images found: {total_images}")
print("-" * 80)

# Step 2: Build product-image mapping
print("\n🔍 Building product-image mappings from CSV files...")
print("-" * 80)

product_image_map = {}

for category in csv_files.keys():
    csv_file = csv_files[category]
    
    if not os.path.exists(csv_file):
        continue
    
    category_images = all_images.get(category, [])
    
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        for row in reader:
            product_name = row['Product Name'].strip()
            image_file, image_path = find_matching_image(product_name, category_images)
            
            if image_file and image_path:
                product_image_map[product_name] = {
                    'category': category,
                    'image_file': image_file,
                    'image_path': image_path
                }

print(f"✅ Found {len(product_image_map)} products with matching images")
print("-" * 80)

# Step 3: Upload images to ImgBB
print("\n📤 Uploading images to ImgBB...")
print("=" * 80)
print("⚠️  This may take a while... Please be patient!")
print("-" * 80)

uploaded_urls = {}
upload_count = 0
error_count = 0

for product_name, info in product_image_map.items():
    image_path = info['image_path']
    image_file = info['image_file']
    
    # Check if already uploaded (to avoid duplicates)
    if image_file in uploaded_urls:
        print(f"  ⏭️  Skipping (already uploaded): {image_file}")
        product_image_map[product_name]['url'] = uploaded_urls[image_file]
        continue
    
    print(f"\n[{upload_count + 1}/{len(product_image_map)}] Uploading: {image_file}")
    
    # Upload to ImgBB
    url = upload_to_imgbb(image_path, image_file)
    
    if url:
        print(f"  ✅ Success! URL: {url[:60]}...")
        uploaded_urls[image_file] = url
        product_image_map[product_name]['url'] = url
        upload_count += 1
    else:
        print(f"  ❌ Failed to upload")
        error_count += 1
    
    # Rate limiting - wait a bit between uploads
    time.sleep(0.5)
    
    # Progress update every 50 images
    if (upload_count + error_count) % 50 == 0:
        print(f"\n📊 Progress: {upload_count} uploaded, {error_count} errors")
        print("-" * 80)

print("\n" + "=" * 80)
print(f"📤 Upload complete!")
print(f"✅ Successfully uploaded: {upload_count}")
print(f"❌ Failed: {error_count}")
print("-" * 80)

# Step 4: Update Firestore
print("\n🔄 Updating Firestore products...")
print("=" * 80)

products_ref = db.collection('Products')
all_firestore_products = products_ref.stream()

updated_count = 0
deleted_count = 0

for doc in all_firestore_products:
    product_data = doc.to_dict()
    product_name = product_data.get('title', '')
    doc_id = doc.id
    
    if product_name in product_image_map and 'url' in product_image_map[product_name]:
        # Update with ImgBB URL
        url = product_image_map[product_name]['url']
        
        try:
            db.collection('Products').document(doc_id).update({
                'thumbnail': url,
                'images': [url],
                'hasImage': True
            })
            updated_count += 1
            
            if updated_count % 100 == 0:
                print(f"  ⏳ Updated {updated_count} products...")
        except Exception as e:
            print(f"  ❌ Error updating {product_name}: {e}")
    else:
        # No image found - delete product
        try:
            db.collection('Products').document(doc_id).delete()
            deleted_count += 1
            
            if deleted_count % 50 == 0:
                print(f"  🗑️  Deleted {deleted_count} products...")
        except Exception as e:
            print(f"  ❌ Error deleting {product_name}: {e}")

# Final Summary
print("\n" + "=" * 80)
print("🎉 ALL DONE!")
print("=" * 80)
print(f"📤 Images uploaded to ImgBB: {upload_count}")
print(f"✅ Firestore products updated: {updated_count}")
print(f"🗑️  Products deleted (no images): {deleted_count}")
print(f"📦 Final product count: {updated_count}")
print("=" * 80)
print(f"\n🔗 View Firestore: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 80)
print("\n✅ All products now have public image URLs from ImgBB!")
print("=" * 80)
