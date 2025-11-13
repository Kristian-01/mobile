import os
import re
import csv
import firebase_admin
from firebase_admin import credentials, firestore
import requests
import base64
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock

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

# Concurrent upload settings
MAX_WORKERS = 10  # Upload 10 images at the same time
RETRY_ATTEMPTS = 3

# Thread-safe counters
upload_lock = Lock()
upload_count = 0
error_count = 0
skip_count = 0

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

def upload_to_imgbb(image_path, image_name, retry=0):
    """Upload image to ImgBB and return URL with retry logic"""
    global upload_count, error_count
    
    try:
        with open(image_path, 'rb') as file:
            image_data = base64.b64encode(file.read()).decode('utf-8')
            
            payload = {
                'key': IMGBB_API_KEY,
                'image': image_data,
                'name': image_name
            }
            
            response = requests.post(IMGBB_UPLOAD_URL, data=payload, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    with upload_lock:
                        upload_count += 1
                    return result['data']['url']
                else:
                    error_msg = result.get('error', {}).get('message', 'Unknown error')
                    if retry < RETRY_ATTEMPTS:
                        time.sleep(1)
                        return upload_to_imgbb(image_path, image_name, retry + 1)
                    with upload_lock:
                        error_count += 1
                    return None
            else:
                if retry < RETRY_ATTEMPTS:
                    time.sleep(1)
                    return upload_to_imgbb(image_path, image_name, retry + 1)
                with upload_lock:
                    error_count += 1
                return None
                
    except Exception as e:
        if retry < RETRY_ATTEMPTS:
            time.sleep(1)
            return upload_to_imgbb(image_path, image_name, retry + 1)
        with upload_lock:
            error_count += 1
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

def upload_single_product(product_name, info, uploaded_urls):
    """Upload a single product's image"""
    global skip_count
    
    image_path = info['image_path']
    image_file = info['image_file']
    
    # Check if already uploaded
    if image_file in uploaded_urls:
        with upload_lock:
            skip_count += 1
        return product_name, uploaded_urls[image_file], True
    
    # Upload to ImgBB
    url = upload_to_imgbb(image_path, image_file)
    
    if url:
        uploaded_urls[image_file] = url
        return product_name, url, False
    else:
        return product_name, None, False

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
print("\n🔍 Building product-image mappings...")
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

# Step 3: Parallel upload to ImgBB
print(f"\n📤 Uploading images to ImgBB (using {MAX_WORKERS} parallel workers)...")
print("=" * 80)
print("⚡ This will be much faster!")
print("-" * 80)

uploaded_urls = {}
start_time = time.time()

with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
    # Submit all upload tasks
    future_to_product = {
        executor.submit(upload_single_product, product_name, info, uploaded_urls): product_name
        for product_name, info in product_image_map.items()
    }
    
    # Process completed uploads
    for i, future in enumerate(as_completed(future_to_product), 1):
        product_name = future_to_product[future]
        try:
            product_name, url, was_skipped = future.result()
            
            if url:
                product_image_map[product_name]['url'] = url
            
            # Progress update every 50 uploads
            if i % 50 == 0:
                elapsed = time.time() - start_time
                rate = i / elapsed
                remaining = (len(product_image_map) - i) / rate if rate > 0 else 0
                print(f"📊 Progress: {i}/{len(product_image_map)} | "
                      f"✅ {upload_count} uploaded | "
                      f"⏭️ {skip_count} skipped | "
                      f"❌ {error_count} errors | "
                      f"⏱️ ETA: {int(remaining/60)}m {int(remaining%60)}s")
                
        except Exception as e:
            print(f"  ❌ Error processing {product_name}: {e}")

elapsed_time = time.time() - start_time

print("\n" + "=" * 80)
print(f"📤 Upload complete in {int(elapsed_time/60)}m {int(elapsed_time%60)}s!")
print(f"✅ Successfully uploaded: {upload_count}")
print(f"⏭️ Skipped (duplicates): {skip_count}")
print(f"❌ Failed: {error_count}")
print("-" * 80)

# Step 4: Update Firestore
print("\n🔄 Updating Firestore products...")
print("=" * 80)

products_ref = db.collection('Products')
all_firestore_products = list(products_ref.stream())

updated_count = 0
deleted_count = 0
batch = db.batch()
batch_count = 0

for doc in all_firestore_products:
    product_data = doc.to_dict()
    product_name = product_data.get('title', '')
    doc_id = doc.id
    
    if product_name in product_image_map and 'url' in product_image_map[product_name]:
        # Update with ImgBB URL
        url = product_image_map[product_name]['url']
        
        batch.update(doc.reference, {
            'thumbnail': url,
            'images': [url],
            'hasImage': True
        })
        updated_count += 1
        batch_count += 1
    else:
        # No image - delete
        batch.delete(doc.reference)
        deleted_count += 1
        batch_count += 1
    
    # Commit every 500 operations
    if batch_count >= 500:
        batch.commit()
        batch = db.batch()
        batch_count = 0
        print(f"  ⏳ Processed {updated_count + deleted_count}/{len(all_firestore_products)}...")

# Commit remaining
if batch_count > 0:
    batch.commit()

# Final Summary
print("\n" + "=" * 80)
print("🎉 ALL DONE!")
print("=" * 80)
print(f"📤 Total images uploaded: {upload_count}")
print(f"✅ Firestore products updated: {updated_count}")
print(f"🗑️  Products deleted (no images): {deleted_count}")
print(f"📦 Final product count: {updated_count}")
print(f"⏱️  Total time: {int(elapsed_time/60)}m {int(elapsed_time%60)}s")
print("=" * 80)
print(f"\n🔗 View Firestore: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 80)
print("\n✅ All products now have real images from ImgBB!")
print("🚀 Your Flutter app will now display the actual product images!")
print("=" * 80)
